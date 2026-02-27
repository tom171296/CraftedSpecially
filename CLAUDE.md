# CraftedSpecially
Agent instructions for CraftedSpecially, a demo project used for presenting and trying out new features.

## Project structure
CraftedSpecially is a modular monolith project that uses different modules to make clean separations between the domain.

The project is structured as follows:
- src: Contains the source code for the project, including the main application logic and any supporting modules.
- tests: Contains the test cases for the project, organized by module or feature.
- infra: Contains the infrastructure as code (Bicep files) for deploying the application to Azure.

### Modules
Modules are used to organize the codebase into logical units taht represent different parts of the domain.
Each module contains the following projects:
- ModuleName.Domain: Contains the domain entities, value objects, and domain services.
- ModuleName.Application: Contains the application services, commands, queries and use cases that orchestrate the domain logic.
- ModuleName.Infrastructure: Contains the implementation of the repositories, external services, and any other infrastructure related code for the module.
- ModuleName.UI: Contains the user interface components, such as controllers, views, and API endpoints for the module.

#### Application project structure
The application uses vertical slicing, which means that the code is organized by use case rather than by technical layer. Each use case 
is implemented as a separate class that contains the necessary logic to execute the use case, including validation, domain logic, and interaction with the infrastructure.

#### Domain project structure
The domain project contains the core business logic of the application. It includes entities, value objects, and domain services that represent the concepts and rules of the business domain. The domain project should be independent of any infrastructure or application concerns, allowing it to be easily tested and maintained.

## Development guidelines
TODO

## Infrastructure
CraftedSpecially uses Azure for hosting. The application is deployed in a container app.
The infrastructure is defined using Bicep. The bicep files are located in the `infra` folder.

The structure of the `infra` folder is as follows:


## Tests
TODO - Most important for automating agentic coding.