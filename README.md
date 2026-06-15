# Avalara AvaTax Integration for Xano

Calculate sales and use tax in real time from your Xano backend: verify connectivity, list your AvaTax companies, calculate tax on a document, and commit or void transactions through the AvaTax REST v2 API.

## Functions

| Function | Description |
| --- | --- |
| `avalara_ping` | Test connectivity and credentials. |
| `avalara_list_companies` | List the companies in your AvaTax account. |
| `avalara_create_transaction` | Calculate tax for a document. |
| `avalara_commit_transaction` | Mark a transaction as Committed. |
| `avalara_void_transaction` | Cancel a transaction. |

## Install

### Option A — Ask Claude Code

With the [Xano MCP](https://github.com/xano-labs/mcp-server) enabled in Claude Code, paste this into Claude:

> Install the integration at https://github.com/xano-community/integration-avalara-tax into my Xano workspace.

Claude will clone the repo and push the functions to your workspace.

### Option B — Use the Xano CLI

1. Install and authenticate the [Xano CLI](https://docs.xano.com/cli):
   ```sh
   npm install -g @xano/cli
   xano auth
   ```

2. Clone and push this integration:
   ```sh
   git clone https://github.com/xano-community/integration-avalara-tax.git
   cd integration-avalara-tax
   xano workspace:push . -w <your-workspace-id>
   ```

   Replace `<your-workspace-id>` with the ID from `xano workspace:list`.

## Configure Credentials

1. In the Avalara Admin Console, get your Account ID and generate a License Key (Settings > License and API keys). 2. Decide on environment: set AVALARA_BASE_URL to https://sandbox-rest.avatax.com for testing or https://rest.avatax.com for production (sandbox needs sandbox credentials). 3. In your Xano workspace settings, add AVALARA_BASE_URL, AVALARA_ACCOUNT_ID, and AVALARA_LICENSE_KEY. 4. Call avalara_ping to confirm the credentials are recognized.

Environment variables used by this integration:

- `AVALARA_ACCOUNT_ID`
- `AVALARA_BASE_URL`
- `AVALARA_LICENSE_KEY`

See `.env.example` for a template.

## Usage

Call any function from another function, task, or API endpoint using `function.run`:

```xs
function.run "avalara_ping" {
  input = {
    // See function signature for required parameters
  }
} as $result
```

## Function Reference

### `avalara_ping`

Calls the AvaTax utilities/ping endpoint to confirm your application can reach AvaTax and that your credentials are recognized. Returns the API version and authentication status — a quick health check before calculating tax.

### `avalara_list_companies`

Returns the companies configured in your AvaTax account, with company code, name, and active/default flags. Supports optional filter, top, and skip parameters. Use the returned companyCode when creating transactions.

### `avalara_create_transaction`

Creates an AvaTax transaction (SalesInvoice by default) from line items and ship-from/ship-to addresses, returning a full tax calculation with totals and per-jurisdiction breakdowns. Set commit=true to record it as committed immediately.

### `avalara_commit_transaction`

Commits a previously saved transaction by company code and transaction code, changing its status to Committed so it is included in your tax filings.

### `avalara_void_transaction`

Voids (cancels) a transaction by company code and transaction code with a void reason, removing it from tax liability.

## License

MIT — see [LICENSE](./LICENSE).
