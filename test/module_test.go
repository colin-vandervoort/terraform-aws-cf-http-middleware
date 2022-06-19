package test

import (
	"crypto/tls"
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestViewerReq(t *testing.T) {

	testUrlActions := map[string]interface{}{
		"/foo": map[string]interface{}{
			"target": "/foo/",
			"code":   301,
		},
		"/bar/": map[string]interface{}{
			"target": "/baz/",
			"code":   301,
		},
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit",
		Vars: map[string]interface{}{
			"dynamodb_url_action_table_name":  "cf-http-middleware-test-action-table",
			"lambda_zip_bucket_name":          "spacey-artifacts",
			"lambda_viewer_req_zip_filename":  "cf-viewer-req.zip",
			"lambda_origin_resp_zip_filename": "cf-origin-resp.zip",
			"dynamodb_url_action_table_items": testUrlActions,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	trailingSlashOutput := terraform.Output(t, terraformOptions, "test_add_trailing_slash_result")
	fmt.Print(trailingSlashOutput)
}

func TestSystem(t *testing.T) {
	t.Skip() // FIXME this test doesn't work
	indexDocString := "<!doctype html><title>index</title>"
	fooDocString := "<!doctype html><title>foo</title>"
	bazDocString := "<!doctype html><title>baz</title>"

	testPages := map[string]interface{}{
		"index.html": map[string]interface{}{
			"content": indexDocString,
		},
		"foo/index.html": map[string]interface{}{
			"content": fooDocString,
		},
		"baz/index.html": map[string]interface{}{
			"content": bazDocString,
		},
	}

	testUrlActions := map[string]interface{}{
		"/foo": map[string]interface{}{
			"target": "/foo/",
			"code":   301,
		},
		"/bar/": map[string]interface{}{
			"target": "/baz/",
			"code":   301,
		},
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./integration",
		Vars: map[string]interface{}{
			"dynamodb_url_action_table_name":  "cf-http-middleware-test-action-table",
			"lambda_zip_bucket_name":          "spacey-artifacts",
			"lambda_viewer_req_zip_filename":  "cf-viewer-req.zip",
			"lambda_origin_resp_zip_filename": "cf-origin-resp.zip",
			"cf_origin_bucket_name":           "cf-http-middleware-test-origin-bucket",
			"s3_origin_objects":               testPages,
			"dynamodb_url_action_table_items": testUrlActions,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	cfDomain := terraform.Output(t, terraformOptions, "cf_dist_domain")
	cfOrigin := fmt.Sprintf("https://%s", cfDomain)

	rootUrl := fmt.Sprintf("%s/", cfOrigin)
	fooUrlNoTrailingSlash := fmt.Sprintf("%s/foo", cfOrigin)
	fooUrl := fmt.Sprintf("%s/foo/", cfOrigin)
	barUrl := fmt.Sprintf("%s/bar/", cfOrigin)
	bazUrl := fmt.Sprintf("%s/baz/", cfOrigin)

	tlsConfig := tls.Config{}
	maxRetries := 5
	timeBetweenRetries := 5 * time.Second

	// Non-redirect tests
	http_helper.HttpGetWithRetry(t, rootUrl, &tlsConfig, 200, indexDocString, maxRetries, timeBetweenRetries)
	http_helper.HttpGetWithRetry(t, fooUrl, &tlsConfig, 200, fooDocString, maxRetries, timeBetweenRetries)
	http_helper.HttpGetWithRetry(t, bazUrl, &tlsConfig, 200, bazDocString, maxRetries, timeBetweenRetries)

	// test redirects
	http_helper.HttpGetWithRetry(t, barUrl, &tlsConfig, 200, bazDocString, maxRetries, timeBetweenRetries)
	http_helper.HttpGetWithRetry(t, fooUrlNoTrailingSlash, &tlsConfig, 200, fooDocString, maxRetries, timeBetweenRetries)
}
