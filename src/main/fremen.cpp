#include <iostream>
#include <fstream>	
#include <cstdlib>	
#include <stdlib.h>	
#include "CFrelement.h"
#include "CPerGaM.h"
#include "CTimeAdaptiveHist.h"
#include "CTimeHist.h"
#include "CSpaceHist.h"
#include "CTimer.h"
#define MAX_SIGNAL_LENGTH 10000000
#define DAY_LENGTH 1440
#define GRANULARITY 60 
#define MAX_ACTIVITIES 20 
#define MAX_LOCATIONS 20 

char locationStr[MAX_LOCATIONS][100];
char activityStr[MAX_LOCATIONS][100];

unsigned char dummy;

CSpatial *spatialModels[MAX_ACTIVITIES];
CTemporal *temporalModels[MAX_ACTIVITIES];
int length = 0;
int activity[MAX_SIGNAL_LENGTH];
int locations[MAX_SIGNAL_LENGTH];

float locAct[MAX_LOCATIONS][MAX_ACTIVITIES];
float locGround[MAX_LOCATIONS][MAX_ACTIVITIES];
int activityCount[MAX_ACTIVITIES];
int locationVisitCount[MAX_ACTIVITIES];
float confMat[MAX_ACTIVITIES][MAX_ACTIVITIES];
float newConfMat[MAX_ACTIVITIES][MAX_ACTIVITIES];
float confusion = 0.1;
float precision = 0.2;

int numActivities = 0;
int numLocations = 0;

/*initialize confusion matrix*/
void initMatrix(float diag)
{
	precision = diag;
	confusion = (1-diag)/(numActivities-1);
	for (int i=0;i<numActivities;i++){
		for (int j=0;j<numActivities;j++) confMat[i][j] = confusion; 
	}
	for (int i=0;i<numActivities;i++) confMat[i][i] = diag;
}

int initMatrixFile(char* filename)
{
    int i=0;
    FILE* file=fopen(filename,"r");

    while (feof(file)==0)
    {
        //fscanf(file,"%f ",&temp);
        for (int k=0;k<numActivities-1;k++)fscanf(file,"%f ",&confMat[i][k]);
        fscanf(file,"%f\n",&confMat[i][numActivities-1]);
        //fscanf(file,"%f %f %f %f %f %f %f %f %f %f %f %f\n",&confMat[i][0],&confMat[i][1],&confMat[i][2],&confMat[i][3],&confMat[i][4],&confMat[i][5],&confMat[i][6],&confMat[i][7],&confMat[i][8],&confMat[i][9],&confMat[i][10],&confMat[i][11]);
        //confMat[i][j]=temp;
        //printf("INDEX: confMat(%d,%d) -> %f\n",i,j,confMat[i][j]);

        /*j=(j+1)%size;
        if (j==0)
        {
            i++;
            fscanf(file,"\n");
        }*/
        i++;
    }
    fclose(file);
    printf("CONFUSION MATRIX:\n\n");
    for (int i=0;i<numActivities;i++)
    {
    for (int j=0;j<numActivities;j++)printf("%.3f ",confMat[i][j]);
    printf("\n");
    }
    printf("\n");
    printf("\n");
      return 0;
}

/*simulate the recognition process*/
int recognizeActivity(int which,int when)
{
	float wheel[numActivities];
	int j = 0; 
	uint32_t minute = when*60;
	float sumP = 0;	
	int room = locations[when];

	/*calculate and normalise posteriors*/
	for (j = 0;j<numActivities;j++)wheel[j]=confMat[which][j]*temporalModels[j]->predict(minute)*spatialModels[j]->predict(room);
	for (j = 0;j<numActivities;j++)sumP+=wheel[j];
	for (j = 0;j<numActivities;j++)wheel[j]=wheel[j]/sumP;

	/*construct the roullette wheeel*/
	for (j = 1;j<numActivities;j++)wheel[j]+=wheel[j-1];
		
	/*and throw the dice*/
	float randomThrow = wheel[numActivities-1]*((float)rand())/RAND_MAX;
	for (j = 0;j<numActivities && randomThrow > wheel[j];j++){}

	/*update the spatio-temporal models*/
	float denom = 0;

	float value = 0;
	for (int k = 0;k<numActivities;k++)
	{
		/*joint update of the spatio-temporal models*/
		denom = 0;
		for (int l = 0;l<numActivities;l++) denom += confMat[l][j]*temporalModels[l]->estimate(minute)*spatialModels[l]->estimate(room);
		value = confMat[k][j]*temporalModels[k]->estimate(minute)*spatialModels[k]->estimate(room)/denom;
		if (spatialModels[k]->type != ST_NONE) spatialModels[k]->add(room,value);
		if (temporalModels[k]->type == TT_FREMEN || temporalModels[k]->type == TT_PERGAM){
			if (k==j) value = 1; else value = 0;
		}
		if (temporalModels[k]->type != TT_NONE) temporalModels[k]->add(minute,value);

		/*separate update of the spatial models*/
		denom = 0;
		for (int l = 0;l<numActivities;l++) denom += confMat[k][l]*spatialModels[l]->estimate(room);
		value = confMat[j][k]*spatialModels[k]->estimate(room)/denom;
		//spatialModels[k]->add(room,value);

		/*separate update of the temporal models*/
		denom = 0;
		for (int l = 0;l<numActivities;l++) denom += confMat[k][l]*temporalModels[l]->estimate(minute);
		value = confMat[j][k]*temporalModels[k]->estimate(minute)/denom;
		if (k==j) value = 1; else value = 0;
		//temporalModels[k]->add(minute,value);
	}
	locAct[room][j]++;
	//for (int j=0;j<numActivities;j++) temporalModels[j]->update(0);
	//for (int j=0;j<numActivities;j++) spatialModels[j]->update(0);
	return j;
}

//demo
int main(int argc,char *argv[])
{
	/*read the activity timeline*/
	int dummy;
	length = 0;
	char filename[100];

	/*load activity timeline*/
	sprintf(filename,"%s/activity.min",argv[1]);
	FILE* file=fopen(filename,"r");
	while (feof(file)==0)
	{

		fscanf(file,"%i\n",&dummy);
		if (dummy > numActivities) numActivities = dummy;
		activity[length]=dummy;
		length++;
	}
	numActivities++;
	fclose(file);

	/*load activity timeline*/
	sprintf(filename,"%s/activity.names",argv[1]);
	file=fopen(filename,"r");
	int numActivityNames = 0;
	while (feof(file)==0)
	{
		fscanf(file,"%s\n",activityStr[numActivityNames++]);
	}
	fclose(file);
	if (numActivityNames != numActivities) fprintf(stderr,"Activity mismatch - timeline suggests %i activities, but there are %i names.\n",numActivities,numActivityNames);

	/*load the locations timeline*/
	length = 0;
	sprintf(filename,"%s/location.min",argv[1]);
	file=fopen(filename,"r");
	while (feof(file)==0)
	{
		fscanf(file,"%i\n",&dummy);
		if (dummy > numLocations) numLocations = dummy;
		locations[length++]=dummy-1;
	}
	numLocations++;
	fclose(file);
	printf("Length %i %i %i\n",length,numLocations,numActivities);

	/*load activity timeline*/
	sprintf(filename,"%s/location.names",argv[1]);
	file=fopen(filename,"r");
	int numLocationNames = 0;
	while (feof(file)==0)
	{
		fscanf(file,"%s\n",locationStr[numLocationNames++]);
	}
	fclose(file);
	if (numLocationNames != numLocations) fprintf(stderr,"Location mismatch - timeline suggests %i locations, but there are %i names.\n",numLocations,numLocationNames);

	/*initialize the location matrix*/
	for (int i=0;i<numLocations*numActivities;i++) locAct[i%numLocations][i/numLocations]=0;
	for (int i=0;i<numLocations*numActivities;i++) locGround[i%numLocations][i/numLocations]=0;

	/*initialize the confusion and location/activity co-ocurerence matrix*/
	//initMatrix(0.2);

	if(argv[5][0]=='0'){
		initMatrix(atof(argv[5]));
	}else{
		initMatrixFile(argv[5]);
	}
	/*print confusion matrix*/
	for (int i=0;i<numActivities;i++){
		for (int j=0;j<numActivities;j++)
		{
			printf("%.2f ",confMat[i][j]);
		}
		printf("\n");
	}
	//exit(0);

	//printf("Address %i\n",((long int)activity[1]-(long int)activity[0]));

	/*spawn spatio-temporal models*/
	if (argv[2][0] == 'H'){//Static Histogram
		for (int i=0;i<numActivities;i++) temporalModels[i] = new CTimeHist(activityStr[i]);
		for (int i=0;i<numActivities;i++) temporalModels[i]->init(86400,atoi(argv[3]));
	}
	if (argv[2][0] == 'A'){//AdaHist
		for (int i=0;i<numActivities;i++) temporalModels[i] = new CTimeAdaptiveHist(activityStr[i]);
		for (int i=0;i<numActivities;i++) temporalModels[i]->init(86400,atoi(argv[3]));// here the argument is the sample threshold
	}
	if (argv[2][0] == 'F'){//Fremen
		for (int i=0;i<numActivities;i++) temporalModels[i] = new CFrelement(activityStr[i]);
		for (int i=0;i<numActivities;i++) temporalModels[i]->init(86400*7,24*7);
	}
	if (argv[2][0] == 'G'){//Gaussian mixtures
		for (int i=0;i<numActivities;i++) temporalModels[i] = new CPerGaM(activityStr[i]);
		for (int i=0;i<numActivities;i++) temporalModels[i]->init(86400,atoi(argv[3]));
	}
	if (argv[2][0] == 'N')
	{//None
		for (int i=0;i<numActivities;i++){
			temporalModels[i] = new CTimeHist(activityStr[i]);
			temporalModels[i]->init(86400,24);
			temporalModels[i]->init(86400,24);
			temporalModels[i]->type = TT_NONE;
		}
	}


	for (int i=0;i<numActivities;i++){ 
		spatialModels[i] = new CSpaceHist(activityStr[i]);
		spatialModels[i]->init(numLocations);
		if (argv[2][1] == 'N') spatialModels[i]->type = ST_NONE;
	}
	for (int day = 0;day<atoi(argv[4]);day++)
	{	
		/*print prior probabilities for the day*/
		printf("Temporal priors\n");
		for (int j=0;j<DAY_LENGTH;j+=60){
			printf("Temporal ");
			for (int i=0;i<numActivities;i++)printf("%.3f ",temporalModels[i]->predict(j*60));
			printf(" \n");
		}

		/*print FreMEn models*/
		printf("Temporal models                              ");
		for (int i=0;i<24;i++)printf(" -%02i- ",i);
		printf("\n");
		for (int i=0;i<numActivities;i++)temporalModels[i]->print(true);
		printf("Spatial models                                 ");
		for (int i=0;i<numLocations;i++)printf("%s ",locationStr[i]);
		printf("\n");
		for (int i=0;i<numActivities;i++)spatialModels[i]->print(true);

		/*initialize confusion matrix*/
		memset(newConfMat,0,numActivities*numActivities*sizeof(float));
		memset(activityCount,0,numActivities*sizeof(int));

		/*simulate activities*/
		int recognised = 0;
		int real = 0;
		int correct = 0;
		int incorrect = 0;
		for (int j=0;j<DAY_LENGTH;j++){
			real = activity[j+day*DAY_LENGTH];
			if (strcmp(activityStr[real],"None")!=0){
				recognised = recognizeActivity(real,j+day*DAY_LENGTH);
				newConfMat[real][recognised]++;
				activityCount[real]++;
				/*if activity is None, then it means that ground truth is missing: ignore results*/
				if (real == recognised) correct++; else incorrect++;
			}
		}

		/*print activity report*/
		printf("Activity: ");
		for (int i=0;i<numActivities;i++) printf("%i ",activityCount[i]);
		printf("\n");

		/*print confusion matrix*/
		for (int i=0;i<numActivities;i++){
			for (int j=0;j<numActivities;j++)
			{
				if (activityCount[i] == 0) newConfMat[i][j]=confMat[i][j];
				if (activityCount[i] > 0)  newConfMat[i][j]=newConfMat[i][j]/activityCount[i];
				printf("%.3f ",newConfMat[i][j]);
				//printf("%.3f ",confMat[i][j]);
			}
			printf("\n");
		}
		printf("Report: \n");
		float trace = 0;
		for (int i=0;i<numActivities;i++){
			printf("%s %.3f \n",activityStr[i],newConfMat[i][i]);
			trace+=newConfMat[i][i];
		}

		printf("Precision %i %i %i %f %f\n",day,correct,incorrect,1.0*correct/(incorrect+correct),trace/numActivities);
		//if (day==atoi(argv[4])-1){for (int j=0;j<numActivities;j++){ if (temporalModels[j]->type != TT_NONE) temporalModels[j]->update(atoi(argv[3]));}}
		for (int j=0;j<numActivities;j++){ if (temporalModels[j]->type != TT_NONE) temporalModels[j]->update(atoi(argv[3]));};
		for (int j=0;j<numActivities;j++){ if (spatialModels[j]->type != ST_NONE) spatialModels[j]->update(atoi(argv[3]));}
		//if (argv[3][0] != 'N') for (int j=0;j<numActivities;j++) temporalModels[j]->update(atoi(argv[4]));
	}

	//room assignment
	float ss=0;
	float sg=0;
	for (int i=0;i<length;i++)locGround[locations[i]][activity[i]]++;
	for (int i=0;i<numLocations*numActivities;i++)ss+=locAct[i%numLocations][i/numLocations];
	for (int i=0;i<numLocations*numActivities;i++)sg+=locGround[i%numLocations][i/numLocations];
	int actRoom[numLocations];
	int actGround[numLocations];
	for (int j=0;j<numLocations;j++)
	{
		float maxRoom = -1;
		float maxGround = -1;
		for (int i=1;i<numActivities;i++){
			if (maxRoom < locAct[j][i]){
				actRoom[j] = i;
				maxRoom = locAct[j][i]; 
			}
			if (maxGround < locGround[j][i]){
				actGround[j] = i;
				maxGround = locGround[j][i]; 
			}
		}
	}

	printf("Spatial models   ");
	for (int i=0;i<numLocations;i++)printf("%s   ",locationStr[i]);
	printf("\n");

	for (int i=0;i<numLocations*numActivities;i++){
		if (i%numLocations == 0) printf("%s ",activityStr[i/numLocations]);
		printf("%.5f ",locGround[i%numLocations][i/numLocations]/sg);
		if (i%numLocations == numLocations-1) printf("\n");
	}
	printf("\n");
	for (int i=0;i<numLocations;i++) printf("%s : %s : %s \n",locationStr[i],activityStr[actGround[i]],activityStr[actRoom[i]]);

	return 0;
}
