# scrape the census website for the city-level California data.
# The final data will be in all.txt, and field descriptions in city_fields.txt

# D. Poole: 12/29/2008

# The file cities_CA.txt has the numeric codes for each city simply cut-and-pasted 
# from the source of page http://quickfacts.census.gov/qfd/states/06000.html

# get city names
awk -F'"' '{ln=index($3,"(");print $2 "," substr($3,2,ln-2);}' cities_CA.txt > /tmp/poole.cities

# go to each city page, scrape the html table and store the data.
foreach i (`awk -F',' '{print $1;}' /tmp/poole.cities`)
 grep $i /tmp/poole.cities
 local_tables.pl "http://quickfacts.census.gov/qfd/states/$i" | gawk -F'|' '(NF==4)' | grep '[A-z]' | awk -F'|' '{print $2 "|" $3;}' > /tmp/poole.current
 set city=`head -1 /tmp/poole.current| awk -F'|' '{print $2;}' | sed 's/ /_/g'`
 mv /tmp/poole.current CityData/"$city".txt
end

# put all the city data into one file (note: the field descriptors are identical for all city files)

cd CityData
rm -f all.txt
foreach i (`ls`)
 awk -F'|' '{if (NR==1) printf("%s",$2);else {if (index($1,"QuickFacts")==0) printf("|%s",$2);}}END{printf("\n");}' $i >> all.txt
end

# get field descriptors (can use any city file since the fields are all the same)
cat Yucaipa.txt |awk -F'|' '{if (NR==1) printf("City\n");else {if (index($1,"QuickFacts")==0) print $1;}}' | awk '{print NR "|" $0;}' > city_fields.txt
