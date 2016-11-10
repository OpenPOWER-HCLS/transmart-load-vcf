#!/bin/bash

# (C) Copyright IBM Corp. 2016
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e
# Check input parameters
if [ $# -lt 2 ]
  then
    echo "No or invalid arguments supplied."
    
    echo "Usage: ./load_vcf_and_mapping_data.sh vcf_data_dir"
    echo "    vcf_data_dir is the directory containing the parsed data from the VCF and mapping files"
    echo ""
    echo "Example: ./load_vcf_and_mapping_data.sh /tmp/vcf psql_command"

    exit 1
fi

output_dir=$1
PSQL_COMMAND=$2
DIR=`dirname "$0"`

load_vcf_data_one () {

    TSVFILENAME=$1

    # source the control file, so we know what file
    # to load and what parameters to use
    . "$DIR/../../../common/_scripts/vcf/$TSVFILENAME.ctl"

    # Postgres tab delimiter needs a special format
    if [ $DELIMITER = "\t" ]
    then
        PGDELIMITER="E'\t'"
    else
        PGDELIMITER="'$DELIMITER'"
    fi

    echo "Processing text file $FILENAME"
    $PSQL_COMMAND -c "COPY $TABLE ($COLUMNS) FROM STDIN \
                DELIMITER $PGDELIMITER" < $output_dir/$FILENAME;

}

convert_sql_files () {

    # List of SQL files to be loaded
    SQLFILES=( "load_concept_dimension" "load_observation_fact" \
               "load_i2b2" "load_i2b2_secure" \
	       "load_de_subject_sample_mapping" )

    # Loop through the SQL files
    echo "Converting SQL files"
    for SQLFILE in "${SQLFILES[@]}"
    do

        # Replace calls to sequences in the SQL files
        # Replace calls to nextval and currval
        perl -pe "s/([a-zA-Z0-9\._]*)\.(curr|next)val/\2val( '\1' )/g; s/from dual//g" < "$output_dir/$SQLFILE.sql" > "$output_dir/$SQLFILE.postgres.sql"

    done

}

load_mapping_data_one () {

    SQLFILENAME=$1

    echo "Processing SQL file $SQLFILENAME"
    $PSQL_COMMAND -f "$output_dir/$SQLFILENAME.postgres.sql";

}

load_variant_subject_summary_and_subject_sample_mapping () {
    load_vcf_data_one load_variant_subject_summary

    # load_de_subject_sample_mapping depends on load_variant_subject_summary
    # and load_concept_dimension
    load_mapping_data_one load_de_subject_sample_mapping
}

# First load the dataset
source $output_dir/load_platform.params
time $PSQL_COMMAND -c "insert into deapp.de_gpl_info (platform, title, marker_type, genome_build, organism) \
		select '$PLATFORM', '$PLATFORM_TITLE', '$MARKER_TYPE', '$GENOME_BUILD', '$ORGANISM' \
		WHERE NOT EXISTS(select platform from deapp.de_gpl_info where platform = '$PLATFORM');"

# List of TSV files to be loaded
TSVFILES=( "load_variant_metadata" "load_variant_subject_idx" \
	    "load_variant_subject_detail" \
	    "load_variant_population_info" 	"load_variant_population_data" )

# First load load_variant_dataset
load_vcf_data_one load_variant_dataset &

# convert sql files for mapping data
convert_sql_files

# load load_concept_dimension first
load_mapping_data_one load_concept_dimension

# wait here
wait

# Loop through the TSV file descriptors
for TSVFILE in "${TSVFILES[@]}"
do
    load_vcf_data_one $TSVFILE &
done

load_variant_subject_summary_and_subject_sample_mapping &

# load_observation_fact depends on load_concept_dimension
load_mapping_data_one load_observation_fact &

# load_i2b2 depends on load_concept_dimension
load_mapping_data_one load_i2b2

# load_i2b2_secure depends on load_i2b2
load_mapping_data_one load_i2b2_secure

# Execute stored procedure to update concept counts
# depends on load_observation_fact and load_i2b2
echo "Processing i2b2_create_concept_counts"
$PSQL_COMMAND -c "select tm_cz.i2b2_create_concept_counts('\\$CONCEPT_PATH\\');"

# Wait for all loads to finish
wait
