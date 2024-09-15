/*---------------------------------------------------------
  The options statement below should be placed
  before the data step when submitting this code.
---------------------------------------------------------*/
options VALIDMEMNAME=EXTEND VALIDVARNAME=ANY;


/*---------------------------------------------------------
  Before this code can run you need to fill in all the
  macro variables below.
---------------------------------------------------------*/
/*---------------------------------------------------------
  Start Macro Variables
---------------------------------------------------------*/
%let SOURCE_HOST=<Hostname>; /* The host name of the CAS server */
%let SOURCE_PORT=<Port>; /* The port of the CAS server */
%let SOURCE_LIB=<Library>; /* The CAS library where the source data resides */
%let SOURCE_DATA=<Tablename>; /* The CAS table name of the source data */
%let DEST_LIB=<Library>; /* The CAS library where the destination data should go */
%let DEST_DATA=<Tablename>; /* The CAS table name where the destination data should go */

/* Open a CAS session and make the CAS libraries available */
options cashost="&SOURCE_HOST" casport=&SOURCE_PORT;
cas mysess;
caslib _all_ assign;

/* Load ASTOREs into CAS memory */
proc casutil;
  Load casdata="ML_BreastCancer_Project.sashdat" incaslib="Models" casout="ML_BreastCancer_Project" outcaslib="casuser" replace;
Quit;

/* Apply the model */
proc cas;
  fcmpact.runProgram /
  inputData={caslib="&SOURCE_LIB" name="&SOURCE_DATA"}
  outputData={caslib="&DEST_LIB" name="&DEST_DATA" replace=1}
  routineCode = "

   /*------------------------------------------
   Generated SAS Scoring Code
     Date             : 11Feb2023:03:11:47
     Locale           : en_US
     Model Type       : Support Vector Machine
     Interval variable: concave points_worst
     Interval variable: area_worst
     Interval variable: area_se
     Interval variable: texture_worst
     Interval variable: texture_mean
     Interval variable: smoothness_worst
     Interval variable: smoothness_mean
     Interval variable: radius_mean
     Interval variable: symmetry_mean
     Class variable   : _va_d__E_diagnosis(_E_diagnosis)
     Response variable: _va_d__E_diagnosis(_E_diagnosis)
     ------------------------------------------*/
/* Temporary Computed Columns */
if (('diagnosis'n = 'M'))then do;
'_va_d__E_diagnosis'n= 0.0;
end;
else do;
if (MISSING('diagnosis'n))then do;
'_va_d__E_diagnosis'n= .;
end;
else do;
'_va_d__E_diagnosis'n= 1.0;
end;
end;
;

/*------------------------------------------*/
declare object ML_BreastCancer_Project(astore);
call ML_BreastCancer_Project.score('CASUSER','ML_BreastCancer_Project');
   /*------------------------------------------*/
   /*_VA_DROP*/ drop '_va_d__E_diagnosis'n 'I__va_d__E_diagnosis'n 'P__va_d__E_diagnosis0'n 'P__va_d__E_diagnosis1'n;
length 'I__va_d__E_diagnosis_11429'n $32;
      'I__va_d__E_diagnosis_11429'n='I__va_d__E_diagnosis'n;
'P__va_d__E_diagnosis0_11429'n='P__va_d__E_diagnosis0'n;
'P__va_d__E_diagnosis1_11429'n='P__va_d__E_diagnosis1'n;
   /*------------------------------------------*/
";

run;
Quit;

/* Persist the output table */
proc casutil;
  Save casdata="&DEST_DATA" incaslib="&DEST_LIB" casout="&DEST_DATA%str(.)sashdat" outcaslib="&DEST_LIB" replace;
Quit;
