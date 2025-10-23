# Grant Access to Event Hub — Readme

## 1️⃣ What is Bicep?

[Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) is a **domain-specific language for deploying Azure resources**.

* Simplifies ARM templates.
* Makes infrastructure-as-code readable and maintainable.
* Bicep files (`.bicep`) compile into ARM JSON templates (`.json`) that Azure can deploy.

---

## 2️⃣ What does this Bicep do?

This template automates **granting a partner access to a specific Azure Event Hub instance**:

* References an **existing Event Hub namespace** and a specific **Event Hub** inside it.
* Creates a **Shared Access Policy (SAS rule)** for that Event Hub.
* Allows you to select the **rights** (`Send`, `Listen`, or both).
* Outputs the **primary connection string** for the partner.
* Optionally **sends the connection string securely to a webhook**.

**You only need to provide:**

* `namespaceName`: Name of the Event Hub namespace.
* `eventHubName`: Name of the Event Hub instance.
* Optionally `policyName`, `rights`, and `webhookUrl`.

---

## 3️⃣ Where to host Bicep and JSON

To make a **public Deploy-to-Azure button**:

1. Host your `.bicep` or `.json` files in a **public GitHub repository**.
2. Azure Deploy button currently requires the **JSON version**.
3. Use the **raw file URL** in the Deploy button:

```
https://raw.githubusercontent.com/<username>/<repo>/main/<file>.json
```

* Ensure it’s the raw text URL, not the HTML preview.
* For guaranteed compatibility, **compile the Bicep file to JSON** first.

---

## 4️⃣ How to convert Bicep to JSON

1. Install [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install).
2. Run:

```bash
bicep build grant-access-to-partner.bicep
```

* This produces `grant-access-to-partner.json`.
* Use the `.json` file for the Deploy button.

---

## 5️⃣ Using the Deploy-to-Azure Button

Example:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F<username>%2F<repo>%2Fmain%2Fgrant-access-to-partner.json)

* Click the button → Azure Portal opens → template preloaded.
* Fill in parameters: `namespaceName`, `eventHubName`, `policyName`, `rights`, `webhookUrl` (optional).
* Deploy → outputs connection string for the partner.
* **Note:** Outputs tab is not shown by default — click it to view connection string.

---

## 6️⃣ Tips for Partners

* Use **exact namespace and Event Hub names** — case-sensitive, no spaces.
* Copy the **connection string** securely if webhook is not used.
* If `webhookUrl` is provided, the SAS key will be **sent automatically** via POST to that URL.

---

## 7️⃣ Optional Improvements / Next Steps

* Use a **Key Vault** to store connection strings instead of sending them in plain text.
* Rotate SAS keys regularly for security.
* Consider generating **time-limited SAS tokens** for temporary partner access.
* Predefine allowed `policyName` values or enforce naming conventions to reduce errors.
