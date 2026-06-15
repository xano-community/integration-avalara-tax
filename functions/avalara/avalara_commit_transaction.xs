function "avalara_commit_transaction" {
  description = "Commit a previously created AvaTax transaction (changes status to Committed)"
  input {
    text company_code { description = "The company code that owns the transaction" }
    text transaction_code { description = "The transaction code (document code) to commit" }
  }
  stack {
    var $creds { value = $env.AVALARA_ACCOUNT_ID ~ ":" ~ $env.AVALARA_LICENSE_KEY }
    var $basic { value = "Basic " ~ ($creds|base64_encode) }

    var $url { value = $env.AVALARA_BASE_URL ~ "/api/v2/companies/" ~ ($input.company_code|url_encode) ~ "/transactions/" ~ ($input.transaction_code|url_encode) ~ "/commit" }

    api.request {
      url = $url
      method = "POST"
      headers = [$basic, "Content-Type: application/json", "X-Avalara-Client: Xano-Integration; 1.0; Custom; ; "]
      params = { commit: true }
      mock = {
        "commits transaction": { response: { status: 200, result: { id: 9988776655, code: "INV-1001", status: "Committed", type: "SalesInvoice", totalAmount: 100.00, totalTax: 8.75 } } }
      }
    } as $api_result

    precondition (($api_result.response.status >= 200) && ($api_result.response.status < 300)) {
      error_type = "standard"
      error = "Avalara API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "commits transaction" {
    input = { company_code: "DEFAULT", transaction_code: "INV-1001" }
    expect.to_not_be_null ($response.status)
  }
}
