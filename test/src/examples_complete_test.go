package test

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	"golang.org/x/exp/maps"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

func TestExamplesCompleteWithKeyAndPasswordInSSM(t *testing.T) {
	t.Parallel()
	testExamplesCompleteWithKeyInSSM(t, true)
}

func TestExamplesCompleteWithKeyButNoPasswordInSSM(t *testing.T) {
	t.Parallel()
	testExamplesCompleteWithKeyInSSM(t, false)
}

// Test the Terraform module in examples/complete using Terratest.
func testExamplesCompleteWithKeyInSSM(t *testing.T, smtpPasswordEnabled bool) {
	ssmClient := ssm.NewFromConfig(AWSConfig("us-east-2"))

	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes":                    attributes,
			"create_iam_access_key":         true,
			"ssm_enabled":                   true,
			"ssm_ses_smtp_password_enabled": smtpPasswordEnabled,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform outputAll` to get a map of all the output values,
	// so we can verify certain values are NOT output.
	output := terraform.OutputAll(t, terraformOptions)
	outputKeys := maps.Keys(output)

	expectedUserName := "eg-test-system-user-" + randID
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, output["user_name"])
	AssertSSMParameterEqual(t, ssmClient, output, "access_key_id_ssm_path", "access_key_id")
	if assert.NotEmpty(t, output["access_key_id"], "No Access Key ID in output") &&
		assert.NotEmpty(t, output["access_key_id_ssm_path"], "No SSM Path for Access Key ID") {

		param, err := ssmClient.GetParameter(context.TODO(), &ssm.GetParameterInput{
			Name:           aws.String(output["access_key_id_ssm_path"].(string)),
			WithDecryption: true,
		})

		if assert.Nil(t, err, "Unable to retrieve Access Key ID from SSM Parameter Store") {
			assert.Equal(t, output["access_key_id"].(string), aws.ToString(param.Parameter.Value))
		}
	}
	AssertSSMParameterNotEmpty(t, ssmClient, output, "secret_access_key_ssm_path")
	if smtpPasswordEnabled {
		AssertSSMParameterNotEmpty(t, ssmClient, output, "ses_smtp_password_v4_ssm_path")
	} else {
		AssertSSMParameterEmpty(t, ssmClient, output, "ses_smtp_password_v4_ssm_path")
	}

	assert.NotContains(t, outputKeys, "secret_access_key", "Secrets should not be output when stored to SSM")
	assert.NotContains(t, outputKeys, "ses_smtp_password_v4", "Secrets should not be output when stored to SSM")
}

func TestExamplesCompleteWithKeyNotInSSM(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes":                    attributes,
			"create_iam_access_key":         true,
			"ssm_enabled":                   false,
			"ssm_ses_smtp_password_enabled": true,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform outputAll` to get a map of all the output values
	output := terraform.OutputAll(t, terraformOptions)
	outputKeys := maps.Keys(output)

	expectedUserName := "eg-test-system-user-" + randID
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, output["user_name"])
	assert.NotEmpty(t, output["access_key_id"], "Access Key ID should be output")
	assert.NotEmpty(t, output["secret_access_key"], "Secret Access Key should be output")
	assert.NotContains(t, outputKeys, "access_key_id_ssm_path", "nothing should be stored in SSM when `create_iam_access_key` is false")
}

func TestExamplesCompleteWithoutKey(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes":                    attributes,
			"create_iam_access_key":         false,
			"ssm_enabled":                   true,
			"ssm_ses_smtp_password_enabled": true,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform outputAll` to get a map of all the output values
	output := terraform.OutputAll(t, terraformOptions)
	outputKeys := maps.Keys(output)

	expectedUserName := "eg-test-system-user-" + randID
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, output["user_name"])

	assert.NotContains(t, outputKeys, "access_key_id", "Access key should not be created when `create_iam_access_key` is false")
	assert.NotContains(t, outputKeys, "access_key_id_ssm_path", "nothing should be stored in SSM when `create_iam_access_key` is false")
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes":            attributes,
			"create_iam_access_key": true,
			"ssm_enabled":           true,
			"enabled":               "false",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	results := terraform.InitAndApply(t, terraformOptions)

	// Should complete successfully without creating or changing any resources
	assert.Contains(t, results, "Resources: 0 added, 0 changed, 0 destroyed.")

	// Run `terraform outputAll` to get a map of all the output values
	output := terraform.OutputAll(t, terraformOptions)
	outputKeys := maps.Keys(output)

	// Verify we're getting back the outputs we expect
	assert.Empty(t, output["user_name"])

	assert.NotContains(t, outputKeys, "access_key_id", "Access key should not be created when `create_iam_access_key` is false")
	assert.NotContains(t, outputKeys, "access_key_id_ssm_path", "nothing should be stored in SSM when `create_iam_access_key` is false")

}
