function "avalara_list_companies" {
  description = "List the companies configured in your AvaTax account"
  input {
    text filter? { description = "Optional AvaTax filter expression, e.g. \"isActive eq true\"" }
    int top? { description = "Maximum number of records to return" }
    int skip? { description = "Number of records to skip (for paging)" }
  }
  stack {
    var $creds { value = $env.AVALARA_ACCOUNT_ID ~ ":" ~ $env.AVALARA_LICENSE_KEY }
    var $basic { value = "Authorization: Basic " ~ ($creds|base64_encode) }

    var $url { value = $env.AVALARA_BASE_URL ~ "/api/v2/companies" }
    var $sep { value = "?" }

    conditional {
      if (($input.filter != null) && ($input.filter != "")) {
        var.update $url { value = $url ~ $sep ~ "$filter=" ~ ($input.filter|url_encode) }
        var.update $sep { value = "&" }
      }
    }
    conditional {
      if (($input.top != null) && ($input.top > 0)) {
        var.update $url { value = $url ~ $sep ~ "$top=" ~ ($input.top|to_text) }
        var.update $sep { value = "&" }
      }
    }
    conditional {
      if (($input.skip != null) && ($input.skip > 0)) {
        var.update $url { value = $url ~ $sep ~ "$skip=" ~ ($input.skip|to_text) }
        var.update $sep { value = "&" }
      }
    }

    api.request {
      url = $url
      method = "GET"
      headers = [$basic, "Content-Type: application/json", "X-Avalara-Client: Xano-Integration; 1.0; Custom; ; "]
      mock = {
        "lists companies": { response: { status: 200, result: { "@recordsetCount": 1, value: [ { id: 12345, companyCode: "DEFAULT", name: "Bobs Hardware", isDefault: true, isActive: true, defaultCountry: "US" } ] } } }
      }
    } as $api_result

    precondition (($api_result.response.status >= 200) && ($api_result.response.status < 300)) {
      error_type = "standard"
      error = "Avalara API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "lists companies" {
    input = { top: 10 }
    expect.to_not_be_null ($response.value)
  }
}
