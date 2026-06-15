function "avalara_ping" {
  description = "Test connectivity and credentials against AvaTax (returns auth status and version)"
  input {
  }
  stack {
    var $creds { value = $env.AVALARA_ACCOUNT_ID ~ ":" ~ $env.AVALARA_LICENSE_KEY }
    var $basic { value = "Basic " ~ ($creds|base64_encode) }

    api.request {
      url = $env.AVALARA_BASE_URL ~ "/api/v2/utilities/ping"
      method = "GET"
      headers = [$basic, "Content-Type: application/json", "X-Avalara-Client: Xano-Integration; 1.0; Custom; ; "]
      mock = {
        "pings successfully": { response: { status: 200, result: { version: "23.10.0", authenticated: true, authenticationType: "LicenseKey", authenticatedUserName: "ULC", authenticatedAccountId: 1100012345 } } }
      }
    } as $api_result

    precondition (($api_result.response.status >= 200) && ($api_result.response.status < 300)) {
      error_type = "standard"
      error = "Avalara API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "pings successfully" {
    input = {}
    expect.to_not_be_null ($response.version)
  }
}
