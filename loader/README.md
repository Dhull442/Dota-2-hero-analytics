### Instructions
- Go to https://github.com/lukasmartinelli/pgfutter/releases and download the suitable executable. This is for converting the csv files into tables without having
to explicitly define the tables. However, this converts all dtypes to text by default.

- Run data_loader.sh to load all the data. Note that there may be necessary path changes

- Run alter_dtypes.sql from the psql client to convert the dtypes to numeric where required
