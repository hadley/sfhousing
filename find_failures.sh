#!/bin/bash

# The same filters will have to be applied to house-sales.csv
if ! test -f addresses.clean
then
  # make a cleaned up copy of addresses.csv; remove quotation marks
  # so it's easier to join this to house-sales (unix join, not R).
  awk -F, 'BEGIN{OFS=","} {
    gsub(/"/,"")
    if ($2 != "") {
     gsub(/  /," ")
     sub(/`b/,"B",$2)
     sub(/`g/,"G",$2)
     sub(/`h/,"H",$2)
     sub(/`l/,"L",$2)
     sub(/`s/,"S",$2)
     sub(/`v/,"V",$2)
     sub(/tiburon/,"Tiburon",$2)
     sub(/Discoverey/,"Discovery",$2)     
     print
   }}' addresses.csv > addresses-clean.csv

  # apply the same filter to hous3-sales.csv
  awk -F, 'BEGIN{OFS=","} {
   gsub(/  /," ")
   sub(/`b/,"B",$2)
   sub(/`g/,"G",$2)
   sub(/`h/,"H",$2)
   sub(/`l/,"L",$2)
   sub(/`s/,"S",$2)
   sub(/`v/,"V",$2)
   sub(/tiburon/,"Tiburon",$2)
   sub(/Discoverey/,"Discovery",$2)
   print
  }' house-sales.csv > house-sales-clean.csv

fi


if ! test -f towns
then
  awk -F, '{print $2}' addresses-clean.csv |\
     sort -u > towns
fi


awk -F, 'BEGIN{OFS=","}{
  if ($6 == "QUALITY_COUNTY_SUBDIVISION_CENTROID" || $6 == "QUALITY_COUNTRY_CENTROID" || $6 == "QUALITY_UNKNOWN" || $6 == "QUALITY_COUNTY_SUBDIVISION_CENTROID")  {
    print
  }}' addresses-clean.csv | sort -t, -k2 >failures.csv


