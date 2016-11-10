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
    
    echo "Usage: ./load_mapping_data.sh vcf_data_dir"
    echo "    vcf_data_dir is the directory containing the parsed data from the VCF and mapping files"
    echo ""
    echo "Example: ./load_mapping_data.sh /tmp/vcf psql_command"

    exit 1
fi
