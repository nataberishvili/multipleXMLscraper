library(XML)
library(xml2)
library(data.table)
library(dplyr)

#read xml files fomr directory (aws s3)

files <- list.files(pattern = ".xml$")
files



data  <- lapply(files, function(x) {
  temp <- read_xml(x) %>% xml_ns_strip
  TaxYr <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/TaxYr" ) )
  ReturnType <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/ReturnTypeCd" ) )
  EIN <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/Filer/EIN" ) ) 
  PrepBusinessName <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/PreparerFirmGrp/PreparerFirmName/BusinessNameLine1Txt" ) )
  BusinessName <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/Filer/BusinessName/BusinessNameLine1Txt" ) )
  Address <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/Filer/USAddress/AddressLine1Txt" ) )
  City <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/Filer/USAddress/CityNm" ) )
  State <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/Filer/USAddress/StateAbbreviationCd" ) )
  Zip <- xml_text( xml_find_all( temp, "/Return/ReturnHeader/PreparerFirmGrp/PreparerUSAddress/ZIPCd" ) )
  totalassets <- xml_text( xml_find_all( temp, "//Return/ReturnData/IRS990/TotalAssetsEOYAmt" ) )
  totalliabl <- xml_text( xml_find_all( temp, "//Return/ReturnData/IRS990/TotalLiabilitiesEOYAmt" ) )
  contributiongrantsamt <- xml_text( xml_find_all( temp, "//Return/ReturnData/IRS990/CYContributionsGrantsAmt" ) )
  salariescompempbn <- xml_text( xml_find_all( temp, "//Return/ReturnData/IRS990/CYSalariesCompEmpBnftPaidAmt" ) )
  Taxend <- xml_text( xml_find_all( temp, "//Return/ReturnHeader/TaxPeriodEndDt" ) )
  Revenue <- xml_text( xml_find_all( temp, "/Return/ReturnData/IRS990/CYProgramServiceRevenueAmt") )
  Inv.income <- xml_text( xml_find_all ( temp, "//Return/ReturnData/IRS990/CYInvestmentIncomeAmt") )
  Fundraising.exp <- xml_text( xml_find_all ( temp, "//Return/ReturnData/IRS990/CYTotalFundraisingExpenseAmt"))
  Net.assets.fund.balance <- xml_text( xml_find_all( temp, "//Return/ReturnData/IRS990/NetAssetsOrFundBalancesEOYAmt"))
  out  <- data.frame(TaxYr, ReturnType, EIN, PrepBusinessName, BusinessName, Address, City, State, Zip, totalassets, totalliabl, contributiongrantsamt, salariescompempbn,
                     Taxend, Revenue, Inv.income, Fundraising.exp, Net.assets.fund.balance)
  
  names(out) <- x
  out
  
})
do.call(cbind, data)



#unlist and create a dataframe
df <- as.data.frame(matrix(unlist(data, recursive = T), ncol = 18, byrow = T)[, -1])

#rename the columns
setnames(df, c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", "V15", "V16", "V17"), c("ReturnType", "EIN", "PrepBusinessName", "BusinessName", "Address", "City", "State", "Zip", "totalassets", "totalliabl", "contributiongrantsamt", "salariescompempbn",
                                                                                                                              "Taxend", "Revenue", "Inv.income", "Fundraising.exp", "Net.assets.fund.balance"))


#to data.table
df <- as.data.table(df)

#write as csv
write.csv(df, "data990.csv")
