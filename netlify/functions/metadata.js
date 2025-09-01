exports.handler = async (event, context) => {
  const baseUrl = https://;
  return {
    statusCode: 200,
    headers: { "Access-Control-Allow-Origin": "*" },
    body: JSON.stringify({
      name: "Universal Reconciliation Service",
      identifierSpace: "http://example.com/identifiers",
      schemaSpace: "http://example.com/schemas",
      defaultTypes: [{ id: "/general", name: "General Entity" }],
      view: { url: "http://example.com/view/{{id}}" },
      preview: { url: ${baseUrl}/preview?id={{id}}, width: 400, height: 200 },
      suggest: {
        entity: { service_url: baseUrl, service_path: "/suggest/entity" },
        type: { service_url: baseUrl, service_path: "/suggest/type" },
        property: { service_url: baseUrl, service_path: "/suggest/property" },
      },
      extend: {
        propose_properties: { service_url: baseUrl, service_path: "/extend/propose" },
        property_settings: [
          { name: "maxItems", label: "Maximum number of values", type: "number", default: 1 },
        ],
      },
    }),
  };
};
