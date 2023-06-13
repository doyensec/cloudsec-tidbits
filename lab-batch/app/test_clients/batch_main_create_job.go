package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/batch"
)

func main() {

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1")},
	)

	commands := []*string{}
	commands = append(commands, aws.String("/bin/sh"))
	commands = append(commands, aws.String("-c"))
	commands = append(commands, aws.String("env ; ls -lah ; ps ; tree"))

	batch_svc := batch.New(sess)

	input := &batch.SubmitJobInput{
		JobDefinition:              aws.String("batch-ex-terraform"),
		JobName:                    aws.String("sss"),
		JobQueue:                   aws.String("LowPriorityEc2"),
		ShareIdentifier:            aws.String("scd"),
		SchedulingPriorityOverride: aws.Int64(1),

		ContainerOverrides: &batch.ContainerOverrides{
			Command: commands,
		},
	}

	result, err := batch_svc.SubmitJob(input)
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
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	fmt.Println(result)

}
