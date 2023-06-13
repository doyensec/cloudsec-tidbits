package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/batch"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/gorilla/mux"
)

// Request POST /get-job-result
func getJobResult(w http.ResponseWriter, r *http.Request) {

	type JobData struct {
		JobId string `json: "identifier"`
	}

	type JobDataResponse struct {
		JobId        string `json: "job_id"`
		Status       string `json: "status"`
		StatusReason string `json: "stauts_reason"`
		Content      string `json: "content"`
	}

	var jobdata JobData
	var jobdataResponse JobDataResponse

	reqBody, _ := ioutil.ReadAll(r.Body)

	json.Unmarshal(reqBody, &jobdata)

	fmt.Println("Endpoint /get-job-result endpoint hit - jobId:", jobdata.JobId)

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1")},
	)
	cw_svc := cloudwatchlogs.New(sess)
	batch_svc := batch.New(sess)

	dj_input := &batch.DescribeJobsInput{
		Jobs: []*string{&jobdata.JobId},
	}

	out_job, err := batch_svc.DescribeJobs(dj_input)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
	}

	if len(out_job.Jobs) == 0 {
		fmt.Println("Error Jobs[0] null")
		http.Error(w, err.Error(), 500)
	}

	jobOut := out_job.Jobs[0]

	jobdataResponse.JobId = *jobOut.JobId
	jobdataResponse.Status = *jobOut.Status
	jobdataResponse.StatusReason = *jobOut.StatusReason

	if jobdataResponse.Status != "SUCCEEDED" {
		//w.Header().Set("Content-Type", "application/json")
		//json.NewEncoder(w).Encode(jobdataResponse)
		//return
	}

	logStreamName := *jobOut.Container.LogStreamName

	fmt.Println("logStreamName:", logStreamName)

	var buffResult bytes.Buffer

	resp, err := cw_svc.GetLogEvents(&cloudwatchlogs.GetLogEventsInput{
		LogGroupName:  aws.String("/aws/batch/batch-tidbit"),
		LogStreamName: aws.String(logStreamName),
	})
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
	}

	for _, event := range resp.Events {
		if nil != event.Message {
			buffResult.WriteString(*event.Message)
			buffResult.WriteString("\n")
		}
	}

	jobdataResponse.Content = buffResult.String()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(jobdataResponse)
}

// Request POST /ns-command
func nsCommand(w http.ResponseWriter, r *http.Request) {

	type nsData struct {
		DomainName string `json: "domain_name"`
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var nsdata nsData
	json.Unmarshal(reqBody, &nsdata)

	fmt.Println("Endpoint /nsCommand called", nsdata.DomainName)

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1")},
	)

	commands := []*string{}
	commands = append(commands, aws.String("/bin/sh"))
	commands = append(commands, aws.String("-c"))
	commands = append(commands, aws.String(fmt.Sprintf("nslookup %s", nsdata.DomainName)))

	batch_svc := batch.New(sess)

	inputJob := &batch.SubmitJobInput{
		JobDefinition:              aws.String("job-def-fargate"),
		JobName:                    aws.String("job-ns-task"),
		JobQueue:                   aws.String("LowPriority-Fargate"),
		ShareIdentifier:            aws.String("1234"),
		SchedulingPriorityOverride: aws.Int64(1),

		ContainerOverrides: &batch.ContainerOverrides{
			Environment: []*batch.KeyValuePair{
				//&batch.KeyValuePair{
				//	Name:  aws.String("EXECUTION_COMMAND"),
				//	Value: aws.String(nsdata.DomainName),
				//},
			},
			Command: commands,
		},
	}

	resultJob, err := batch_svc.SubmitJob(inputJob)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case batch.ErrCodeClientException:
				fmt.Println(batch.ErrCodeClientException, aerr.Error())
			case batch.ErrCodeServerException:
				fmt.Println(batch.ErrCodeServerException, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			fmt.Println(err.Error())
		}
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resultJob)
}

func main() {

	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/ns-command", nsCommand).Methods("POST")
	router.HandleFunc("/get-job-result", getJobResult).Methods("POST")

	//index.html and frontend assets
	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./frontend/")))

	log.Fatal(http.ListenAndServe(":80", router))
}
