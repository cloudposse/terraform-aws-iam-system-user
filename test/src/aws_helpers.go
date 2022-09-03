package test

// Support AWS operations
// See https://aws.github.io/aws-sdk-go-v2/docs/getting-started/
// and https://pkg.go.dev/github.com/aws/aws-sdk-go-v2
//
// For type conversions, see https://pkg.go.dev/github.com/aws/aws-sdk-go-v2@v1.16.14/aws#hdr-Value_and_Pointer_Conversion_Utilities

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	"github.com/stretchr/testify/assert"
	"log"
	"testing"
)

func AWSConfig(region string) aws.Config {
	// Load the Shared AWS Configuration (~/.aws/config)
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(region))
	if err != nil {
		log.Fatal(err)
	}

	return cfg
}

func AssertSSMParameterEqual(t *testing.T, ssmClient *ssm.Client, output map[string]interface{}, ssmPathOutput string, expectedValueOutput string) {

	if assert.NotEmpty(t, output[expectedValueOutput], "Missing "+expectedValueOutput) &&
		assert.NotEmpty(t, output[ssmPathOutput], "Missing "+ssmPathOutput) {

		param, err := ssmClient.GetParameter(context.TODO(), &ssm.GetParameterInput{
			Name:           aws.String(output[ssmPathOutput].(string)),
			WithDecryption: true,
		})

		if assert.Nil(t, err, "Unable to retrieve "+ssmPathOutput+" from SSM Parameter Store") {
			assert.Equal(t, output[expectedValueOutput].(string), aws.ToString(param.Parameter.Value))
		}
	}
}

func AssertSSMParameterEmpty(t *testing.T, ssmClient *ssm.Client, output map[string]interface{}, ssmPathOutput string) {

	// No path given
	if output[ssmPathOutput] == nil || output[ssmPathOutput] == "" {
		return
	}

	param, err := ssmClient.GetParameter(context.TODO(), &ssm.GetParameterInput{
		Name:           aws.String(output[ssmPathOutput].(string)),
		WithDecryption: true,
	})

	// If a path is given, there should be an empty value to go with it
	if assert.Nil(t, err, "Unable to retrieve "+ssmPathOutput+" from SSM Parameter Store") {
		assert.Empty(t, aws.ToString(param.Parameter.Value), "Found non-empty value for "+ssmPathOutput)
	}
}

func AssertSSMParameterNotEmpty(t *testing.T, ssmClient *ssm.Client, output map[string]interface{}, ssmPathOutput string) {

	if assert.NotEmpty(t, output[ssmPathOutput], "Missing "+ssmPathOutput) {

		param, err := ssmClient.GetParameter(context.TODO(), &ssm.GetParameterInput{
			Name:           aws.String(output[ssmPathOutput].(string)),
			WithDecryption: true,
		})

		if assert.Nil(t, err, "Unable to retrieve "+ssmPathOutput+" from SSM Parameter Store") {
			assert.NotEmpty(t, aws.ToString(param.Parameter.Value), "Retrieved empty value for "+ssmPathOutput)
		}
	}
}
