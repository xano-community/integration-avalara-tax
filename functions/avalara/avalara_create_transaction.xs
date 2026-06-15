function "avalara_create_transaction" {
  description = "Create an AvaTax transaction to calculate sales/use tax for a document"
  input {
    text company_code { description = "The company code that owns this transaction" }
    text date { description = "Document date, YYYY-MM-DD" }
    text customer_code { description = "Customer/vendor code this document is billed to" }
    json lines { description = "Array of line items, e.g. [{ number: \"1\", quantity: 1, amount: 100.00, taxCode: \"P0000000\" }]" }
    json addresses { description = "Addresses object, e.g. { shipFrom: {...}, shipTo: {...} } or { singleLocation: {...} }" }
    text type?="SalesInvoice" { description = "Document type: SalesInvoice, SalesOrder, PurchaseInvoice, ReturnInvoice, etc." }
    bool commit? { description = "If true, commit the transaction immediately" }
  }
  stack {
    var $creds { value = $env.AVALARA_ACCOUNT_ID ~ ":" ~ $env.AVALARA_LICENSE_KEY }
    var $basic { value = "Basic " ~ ($creds|base64_encode) }

    var $params {
      value = {
        type: $input.type,
        companyCode: $input.company_code,
        date: $input.date,
        customerCode: $input.customer_code,
        lines: $input.lines,
        addresses: $input.addresses
      }
    }
    var.update $params { value = $params|set_ifnotempty:"commit":$input.commit }

    api.request {
      url = $env.AVALARA_BASE_URL ~ "/api/v2/transactions/create"
      method = "POST"
      headers = [$basic, "Content-Type: application/json", "X-Avalara-Client: Xano-Integration; 1.0; Custom; ; "]
      params = $params
      mock = {
        "creates transaction": { response: { status: 201, result: { id: 9988776655, code: "INV-1001", companyId: 12345, date: "2026-06-15", status: "Saved", type: "SalesInvoice", totalAmount: 100.00, totalTaxable: 100.00, totalTax: 8.75, totalExempt: 0.00, lines: [ { lineNumber: "1", tax: 8.75, taxableAmount: 100.00 } ], summary: [ { taxName: "CA STATE TAX", rate: 0.0625, tax: 6.25 } ] } } }
      }
    } as $api_result

    precondition (($api_result.response.status >= 200) && ($api_result.response.status < 300)) {
      error_type = "standard"
      error = "Avalara API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates transaction" {
    input = { company_code: "DEFAULT", date: "2026-06-15", customer_code: "CUST-1", lines: [ { number: "1", quantity: 1, amount: 100.00, taxCode: "P0000000" } ], addresses: { shipFrom: { line1: "100 Ravine Lane NE", city: "Bainbridge Island", region: "WA", country: "US", postalCode: "98110" }, shipTo: { line1: "1500 Broadway", city: "New York", region: "NY", country: "US", postalCode: "10036" } }, type: "SalesInvoice" }
    expect.to_not_be_null ($response.id)
    expect.to_not_be_null ($response.totalTax)
  }
}
