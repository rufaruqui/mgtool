/var/log/radial/upload/Akorin-CONNECTIVE-MAR19.xls
Already processed file : /var/log/radial/upload/Angel Finance-Connecitive-May19.xls
Already processed file : /var/log/radial/upload/AUS Visage-CONNECTIVE-MAR19.xls
Already processed file : /var/log/radial/upload/Aus Visage-Connnective-Feb19.xls
Already processed file : /var/log/radial/upload/BLHL - Connecitve - AUG19.xls
Already processed file : /var/log/radial/upload/BLHL - Connecitve - Feb19.xls
Already processed file : /var/log/radial/upload/BLHL - Connecitve - Jan19.xls
Already processed file : /var/log/radial/upload/BLHL - Connecitve - Jul19.xls
Already processed file : /var/log/radial/upload/BLHL - Connecitve - SEP19.xls

ds =  PGDB[:ImportFiles].where(Name:/Connective/)
ds.to_a.each { |row|  SearchClient.insert_single_row(row) }

SRJDA-C
SRJDA-Connecitve-Dec18.xls
SRJDA-CONNECTIVE-MAR19.xls
Sukkar-CONNECTIVE-MAR19.xls