package main

// PreSignup Event Docs: https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-lambda-pre-sign-up.html

import (
	"context"
	"errors"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// HASURA_ENDPOINT and HASURA_ADMIN_SECRET Environment Variables must be set

func init() {
	log.Print("Cold Start")
}

// Adds User to Flow DB
func handleRequest(ctx context.Context, event *events.CognitoEventUserPoolsPreSignup) (
	*events.CognitoEventUserPoolsPreSignup, error,
) {
	// Get Email
	email, ok := event.Request.UserAttributes["email"]
	if !ok {
		err := errors.New("Email not Specified")
		return nil, err
	} else {
		fmt.Printf(email)
	}

	// Get Given Name
	clientMetaDataGivenName, ok := event.Request.ClientMetadata["givenName"]
	if !ok {
		err := errors.New("Given Name not Specified validationData used")
		return nil, err
	} else {
		fmt.Printf(clientMetaDataGivenName)
	}

	// Get Family Name
	clientMetaDataFamilyName, ok := event.Request.ClientMetadata["familyName"]
	if !ok {
		err := errors.New("Family Name not Specified validationData used")
		return nil, err
	} else {
		fmt.Printf(clientMetaDataFamilyName)
	}

	// Get Given Name
	validationDataGivenName, ok := event.Request.ValidationData["givenName"]
	if !ok {
		err := errors.New("Given Name not Specified validationData used")
		return nil, err
	} else {
		fmt.Printf(validationDataGivenName)
	}

	// Get Family Name
	validationDataFamilyName, ok := event.Request.ValidationData["familyName"]
	if !ok {
		err := errors.New("Family Name not Specified validationData used")
		return nil, err
	} else {
		fmt.Printf(validationDataFamilyName)
	}

	// Return event
	return event, nil
}

func main() {
	// Start Lambda
	lambda.Start(handleRequest)
}
