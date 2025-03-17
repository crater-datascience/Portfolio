/* House Price Analysis
	By Andrew Crater
*/

/* Part 1: Import the Bay Area House Price data set from the file '/folders/myfolders/Week8/Bay Area House Price.csv’. 
   Name the data set as house_price.
*/

PROC IMPORT OUT=house_price
	DATAFILE = '/home/u64126310/Week_8/Bay Area House Price.csv'
	DBMS=CSV
	REPLACE;
	GETNAMES=YES;

/* Ensuring variable types imported correctly */

PROC CONTENTS DATA=house_price;
RUN;
/* test print */
PROC PRINT DATA=house_price(obs=5);
	TITLE 'house_price original test';
RUN;

/*
	Part 2: Drop the variables: address, info, z_address, neighborhood, latitude, longitude, and zpid both using Data Statement and PROC SQL. 
	Name the new data set as house_price.
		Note: I will make one table for using DATA and one for PROC SQL.
*/

DATA house_price_data_method;
	SET house_price;
	DROP address info z_address neighborhood latitude longitude zpid;
RUN;

PROC SQL;
	CREATE TABLE house_price_sql_method AS SELECT 
	bathrooms, 
	bedrooms,
	finishedsqft,
	lastsolddate,
	lastsoldprice,
	totalrooms,
	usecode,
	yearbuilt,
	zestimate,
	zipcode
	FROM house_price;
RUN;

PROC PRINT DATA=house_price_data_method(obs=5);
	TITLE 'House price using DATA';
RUN;

PROC PRINT DATA=house_price_sql_method(obs=5);
	TITLE 'House price using SQL method';
RUN;


/*
	As we see, the drops can be done both with the DATA step and PROC SQL

/*
	Part 3: Add a new variable price_per_square_foot defined by lastsoldprice/finishedsqft both using Data Statement and PROC SQL.
	Note: If we make a new variable with both data and proc sql, we will have two versions of that, so I will make two datasets,
	one with data, and one with the other.
*/

DATA house_price_data_method;
	SET house_price_data_method;
	price_per_square_foot = lastsoldprice/finishedsqft;
RUN;

PROC PRINT DATA=house_price_data_method(obs=5);
	TITLE 'New variable DATA step results';
RUN;

/* Our main house_price dataset now has the new variable, we can make a bonus dataset to demonstrate the ability to do it in SQL also */

PROC SQL;
	CREATE TABLE sql_house_price AS SELECT 
	*,
	lastsoldprice/finishedsqft AS price_per_square_foot_SQL
	FROM house_price_sql_method;
RUN;

PROC PRINT DATA=sql_house_price(obs=5);
	TITLE 'sql with new variable';
RUN;

/* We can thusly see that the new variable can be made both with the DATA step and PROC sql */

/*
	Part 4: Find the average of lastsoldprice by zipcode both using Data Statement and PROC SQL.
	Note: After following up with the professor, I now know to do one with PROC MEANS and one with SQL. */
	
PROC MEANS DATA=house_price_data_method MEAN;
	VAR lastsoldprice;
	CLASS zipcode;
	TITLE 'Average of lastsoldprice by zipcode';
RUN;

PROC SQL;
	CREATE TABLE sql_average AS SELECT
	zipcode,
	AVG(lastsoldprice) AS average_price
	FROM sql_house_price
	GROUP BY zipcode;
	TITLE 'sql average lastsold by zipcode';
	SELECT * FROM sql_average;
RUN;

/*
	Part 5: Find the average of lastsoldprice by usecode, totalrooms, and bedrooms both using Data Statement and PROC SQL.
	Note: I'm going to use PROC MEANS first, then PROC SQL as suggested after follow-up. 
	
*/

PROC MEANS DATA=house_price_data_method MEAN;
	VAR lastsoldprice;
	CLASS usecode totalrooms bedrooms;
	TITLE 'Average of lastsoldprice by usecode, totalrooms, and bedrooms.';
RUN;

PROC SQL;
	CREATE TABLE sql_avg_multi AS SELECT
	usecode,
	totalrooms,
	bedrooms,
	AVG(lastsoldprice) AS average_price
	FROM sql_house_price
	GROUP BY 
	usecode,
	totalrooms,
	bedrooms;
	TITLE 'SQL avg lastsold by usecode, totalrooms, bedrooms';
	SELECT * FROM sql_avg_multi;
RUN;

/*
	Hence, we see that the average of a variable can be calculated by other variables in two ways 
*/

/*
	Part 6: Plot the bar charts for bathrooms, bedrooms, usecode, totalrooms respectively, 
	and save the bar chart of bedrooms as bedrooms.png.
	Note: I will do bedrooms last for convenience. First, we need the sum of 
*/

/* bathrooms */
PROC SGPLOT DATA=house_price_data_method;
	HBAR bathrooms;
	TITLE 'Bar Chart of Bathrooms';
	YAXIS LABEL='Number of Bathrooms';
	XAXIS LABEL='Count';
RUN;

/*usecode*/
PROC SGPLOT DATA=house_price_data_method;
	HBAR usecode;
	TITLE 'Bar Chart of usecode';
	YAXIS LABEL='Number of Properties of Certain usecode';
	XAXIS LABEL='Count';
RUN;
/*totalrooms*/
PROC SGPLOT DATA=house_price_data_method;
	HBAR totalrooms;
	TITLE 'Bar Chart of totalrooms';
	YAXIS LABEL='Number of Total Rooms';
	XAXIS LABEL='Count';
RUN;

/*bedrooms, first we set up the output*/

ODS LISTING GPATH= '/home/u64126310/Week_8';
ODS GRAPHICS / RESET
	IMAGENAME= 'bedrooms'
	OUTPUTFMT= PNG
	HEIGHT = 3IN
	WIDTH= 6IN;

PROC SGPLOT data=house_price_data_method;
	HBAR bedrooms;
	TITLE 'Number of bedrooms';
	YAXIS LABEL='Number of bedrooms';
	XAXIS LABEL= 'Count';
RUN;

ODS LISTING CLOSE;
/*
	Part 7: Plot the Histogram, boxplot for lastsoldprice, zestimate respectively. Are they normal or skewed? 
	What’s the median of the lastsoldprice? What’s the median of the zestimate?
	Note: I thought I could do this with PROC MEANS, but after multiple attempts, I can't get the histogram and boxplot 
	without the qq plot which wasn't asked for. Also, the median is hard to see in the condensed PROC MEANS boxplot, 
	so I will do the plots individually.
*/

PROC SGPLOT DATA=house_price_data_method;
	HISTOGRAM lastsoldprice;
	XAXIS LABEL='lastsoldprice';
	YAXIS LABEL='frequency';
	TITLE 'Histogram of lastsoldprice';
PROC SGPLOT DATA=house_price_data_method;
	VBOX lastsoldprice;
	TITLE 'Boxplot of lastsoldprice';
RUN;

/* We can definitely see that lastsoldprice is right tailed, and definitely not normal, based on the large clump of the data toward the bottom
with many large outliers. We can display the exact median below. */

PROC MEANS DATA=house_price_data_method MEDIAN;
	VAR lastsoldprice;
	TITLE 'median of lastsoldprice';
RUN;
	
/* This shows us that the median is 990000. We can now do the same for zestimate */

PROC SGPLOT DATA=house_price_data_method;
	HISTOGRAM zestimate;
	XAXIS LABEL = 'zestimate';
	YAXIS LABEL = 'frequency';
	TITLE 'Histogram of zestimate';
PROC SGPLOT DATA=house_price_data_method;
	VBOX zestimate;
	TITLE 'Boxplot of zestimate';
RUN;
	
/* Zestimate is also right tailed, and not normal, and is very similarly shaped to lastsoldprice overall. */

PROC MEANS DATA=house_price_data_method MEDIAN;
	VAR zestimate;
	TITLE 'median of zestimate';
RUN;

/* The median for zestimate is 1230758. */

/* 
	Part 8: Calculate the correlation coefficients of all numerical variables with the variable zesitmate, 
	and plot the scatter plot and matrix.  (Hint: Use PLOTS(MAXPOINTS=none)=scatter in PROC CORR  so that the scatter graph is shown. 
	Otherwise you may not see the graph because the data is very large.)

*/

PROC CORR DATA=house_price_data_method PLOTS(MAXPOINTS=none)=scatter;
	VAR zestimate;
	WITH bathrooms bedrooms finishedsqft lastsoldprice totalrooms yearbuilt zestimate price_per_square_foot;
	TITLE 'Correlation of zestimate with numerical variables.';
RUN;
	
/*
	For the next problem, the variables with highest correlation are (in order): lastsoldprice, finishedsqft, bathrooms,bedrooms,yearbuilt.

/*

	Part 9: Find a regression model for zestimate with the first three most correlated variables.
	Note: Turning ODS graphics off like in the class example.
	
*/

ODS GRAPHICS OFF;
PROC REG DATA=house_price_data_method;
	MODEL zestimate=lastsoldprice finishedsqft bathrooms;
	TITLE 'Regression model 1';
RUN;

/* The adjusted r-squared is .8319 */

/*
	Part 10: Find a regression model for zestimate with the first five most correlated variables.
*/

ODS GRAPHICS OFF;
PROC REG DATA=house_price_data_method OUTEST=regout;
	MODEL zestimate=lastsoldprice finishedsqft bathrooms bedrooms yearbuilt;
	TITLE 'Regression model 2';
RUN;


/* The adjusted r-squared is .8328 */

/*
	Part 11: Compare the adjusted R^2 in the two models from question 13) and 14). The model that has a bigger adjusted R^2 is better. 
	We see that the adjusted r^2 for model 2 is .8328 > .8319 from model 1, so model 2 is better.	
*/
	
/*
	Part 12: Use the better model from question 15) to predict the house prices given the values of independent variables. 
	(You name the values of independent variables for  4 houses)
*/

DATA newobs;
   INPUT lastsoldprice finishedsqft bathrooms bedrooms yearbuilt;
   DATALINES;

100000 800 1 1 2015
350000 1500 3.5 3 2015
1120000 2200 4 5 2011
2500000 2890 4 5 2016
;

PROC SCORE DATA=newobs SCORE=regout OUT=newpred TYPE=parms NOSTD PREDICT;
	VAR lastsoldprice finishedsqft bathrooms bedrooms yearbuilt;
RUN;

/* Now we can print the predicted values to check them out */
PROC PRINT DATA=newpred;
	TITLE 'Predicted values';
RUN;

/* Part 13: Export the predictive values from question 16) as an excel file named ‘prediction.xlsx’	*/

PROC EXPORT DATA=newpred
	OUTFILE='/home/u64126310/Week_8/prediction.xlsx'
	DBMS=xlsx
	REPLACE;
RUN;

/*
	Part 14: Create a macro named average with two parameters category and price. In the macro, firstly use PROC MEANS 
	for the data set house_price to calculate the mean of &price by &category. 
	In the PROC MEANS, use option NOPRINT, and let OUT=averageprice. 
	Then use PROC PRINT to print the data averageprice using the macro variables in the TITLE.	
*/

%MACRO average(category=, price=);
	PROC MEANS DATA=house_price_data_method NOPRINT;
		VAR &price;
		CLASS &category;
		OUTPUT OUT=averageprice MEAN=;
	RUN;
	
	PROC PRINT DATA=averageprice;
		TITLE1 "The average (mean) of &price";
		TITLE2 "By &category";
	RUN;
%MEND average;

/*
	Part 15: Call the macro %average(category=zipcode, price=price_per_square_foot).
*/
%average(category=zipcode, price=price_per_square_foot);

/*
	Part 16: Call the macro %average(category=totalrooms, price=zestimate).

*/

%average(category=totalrooms, price=zestimate);