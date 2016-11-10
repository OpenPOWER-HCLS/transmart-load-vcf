# transmart-load-vcf

This provides fast parallel loading of VCF files into TranSMART. You can easily use it by simply replaceing two loading scripts in TranSMART with ours.

## How to install

First, install TranSMART by following the TranSMART foundation's instructions (https://wiki.transmartfoundation.org/display/transmartwiki/Installing+tranSMART).

Assume $TRNSMART_DATA is your TranSMART installation. First, get our load scripts.

    $ git clone https://github.com/OpenPOWER-HCLS/transmart-load-vcf.git
    
Save original scripts if you want.
    
    $ mv $TRANSMART_DATA/samples/postgres/_scripts/vcf/load_vcf_data.sh $TRANSMART_DATA/samples/postgres/_scripts/vcf/load_vcf_data.sh.orig
    $ mv $TRANSMART_DATA/samples/postgres/_scripts/vcf/load_mapping_data.sh $TRANSMART_DATA/samples/postgres/_scripts/vcf/load_mapping_data.sh.orig
    
Then copy our scripts into TranSMART.
    
    $ cp transmart-load-vcf/samples/postgres/_scripts/vcf/load_vcf_data.sh $TRANSMART_DATA/samples/postgres/_scripts/vcf/load_vcf_data.sh
    $ cp transmart-load-vcf/samples/postgres/_scripts/vcf/load_mapping_data.sh $TRANSMART_DATA/samples/postgres/_scripts/vcf/load_mapping_data.sh

We currently support only PostgreSQL.

## How to run

You can use exactly the same loading command you were using. Like

    $ cd $TRANSMART_DATA; make -C samples/postgres load_vcf_Cell-line
