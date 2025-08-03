# Feature: List Available Brews

As a CraftedSpecially enjoyer,
I want to see what types of brews I can order
So that I can choose the one I like best.

## Examples

- User visits the catalog page and sees a list of all available brews.
- Edge case: Catalog is empty, user sees a message indicating no brews are available.
- Failure case: Catalog service is unavailable, user sees an error message.

## Documentation

- Architecture documentation will be added in `docs/architecture` following the ARC42 template:
  - Building Blocks View: Document the Catalog service and its API for listing brews.
  - Runtime View: Document the flow from user request to response, including error handling.
  - Glossary: Add terms such as "brew", "catalog", and "order".

## Other considerations

None.
