
if ! test -f addresses.clean
then
  # make a cleaned up copy of addresses.csv
  sed '1d' addresses.csv | sed 's/\"//g' |\
    awk -F, 'NR > 1 && $2 != "" {print}' |\
    sed 's/  / /; s/`b/B/; s/Discoverey/Discovery/; s/`g/G/; s/`h/H/; s/`los/Los/; s/`s/S/; s/tiburon/Tiburon/; s/`v/V/' > addresses.clean
fi

# The same filters will have to be applied to house-sales.csv

if ! test -f towns
then
  awk -F, '{print $2}' addresses.clean |\
     sort -u > towns
fi

rm -f failures.csv
cat towns | while read line
do
  town=$line
  echo $town
  cat addresses.clean | sed 's/\"//g' |\
    awk -F, -vtown="$town" 'BEGIN{OFS=","} {
      if ($2 == town && ($6 ~ /CITY/ || $6 ~ /ZIP_CODE/ || $6 ~ /COUNTRY/ || $6 ~ /COUNTY/ || $6 ~ /UNMATCH/)) {
        print $1, $3, $4, $5, $6
      }}' |\
      sort -k2 |\
      awk -F, -vtown="$town" 'BEGIN{OFS=","} {{
        print $1, town, $2, $3, $4, $5
      }}' >>failures.csv
done


