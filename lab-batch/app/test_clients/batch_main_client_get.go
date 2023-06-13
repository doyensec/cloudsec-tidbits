package main

import (
	"bytes"
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/batch"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
)

func main() {

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1")},
	)
	cw_svc := cloudwatchlogs.New(sess)
	batch_svc := batch.New(sess)

	jobIdSingle := "b721cc24-256b-41db-b8e4-06e43e82b008"

	dj_input := &batch.DescribeJobsInput{
		Jobs: []*string{&jobIdSingle},
	}

	out_job, err := batch_svc.DescribeJobs(dj_input)
	if err != nil {
		panic("Error DescribeJobs")
	}

	if len(out_job.Jobs) == 0 {
		panic("Error Jobs[0] null")
	}

	jobOut := out_job.Jobs[0]

	logStreamName := *jobOut.Container.LogStreamName

	var buffResult bytes.Buffer

	resp, err := cw_svc.GetLogEvents(&cloudwatchlogs.GetLogEventsInput{
		LogGroupName:  aws.String("/aws/batch/batch-ex-terraform"),
		LogStreamName: aws.String(logStreamName),
	})
	if err != nil {
		fmt.Print(err)
		panic("Error GetLogEvents")
	}

	for _, event := range resp.Events {
		if nil != event.Message {
			buffResult.WriteString(*event.Message)
			buffResult.WriteString("\n")
		}
	}

	fmt.Println(buffResult.String())

}
