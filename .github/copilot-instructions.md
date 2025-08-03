# Github Copilot Instructions

Follow these instructions when writing code or documentation for the project.

## Project goals

This project is used as demo application and playground for the
sessions that I give about software development topics. 

## Project Structure

The .NET services make use of the following structure:
- feature slices

The projects are located at the services directory. .NET Aspire
is used for local development and testing. The services are hosted
on Azure kubernetes services and use a cosmos db database.

The current services are:
- `Catalog`: Contains the catalog of products

For testing, the following types of tests are used:
- Unit tests: located 

## Technology stack

The tehnology stack used in this project is as follows:
- .NET 10
- C#
- Azure Kubernetes Service (AKS)
- Cosmos DB
- GitHub Actions for CI/CD

## Testing the project

- Always create unit-tests for components you introduce into the application.
- After changing or introducing new logic make sure that the tests are updated
  to match the new situation.
- Include at least the following types of test cases:
  - 1 test case for the expected use
  - 1 edge case
  - 1 failure case

## Documenting the code

Make sure to document the code properly in the architecture documentation
located at `docs/architecture`. We follow the arc42 template for structuring
the architecture documentation.

When changing code, make sure to:

- Document important structures in the building blocks view
- Document important flows in the runtime view
- Update the glossary with new terms introduced in the feature