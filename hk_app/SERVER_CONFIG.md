# Server Configuration Guide (Backend Setup)

为了使 App Store 订阅功能完整运行，您需要在后端服务器（`https://hk.xbjy123.com`）上配置以下环境变量或数据库条目。

由于我无法直接访问或修改您的远程服务器，请务必手动完成以下配置。

## 1. App Store Connect API 配置

后端需要使用这些凭据来验证订阅收据和处理服务器通知。

*   **Issuer ID**: `95386b5c-64c7-4fba-88e1-e3037ea9fff3`
*   **Key ID**: `BWCCX3Q472`
*   **Private Key**: (您尚未提供 Private Key 文件内容，通常是一个 `.p8` 文件。请确保将该文件安全地部署到服务器，并在后端配置中指向该文件路径)

## 2. App 内购买密钥 (In-App Purchase Key)

用于处理内购相关的 API 调用。

*   **Issuer ID**: `95386b5c-64c7-4fba-88e1-e3037ea9fff3`
*   **Key ID**: `3B5G82FFGH`

## 3. App 专用共享密钥 (Shared Secret)

这是验证收据（Verify Receipt）的关键凭据。

*   **Shared Secret**: `5bb7d3c0a40947e3864e88f09a3126c7`

请将此密钥配置到后端的 `VERIFY_RECEIPT_SHARED_SECRET` 或相应的环境变量中。

## 4. 订阅产品 ID 配置 (数据库更新)

请确保后端数据库中的 `plans` 表包含以下产品 ID，以便 API (`/api/plans`) 返回正确的数据：

| 订阅类型 | 产品 ID (appleProductId) | 价格 (参考) | 时长 |
| :--- | :--- | :--- | :--- |
| 月度会员 | `huiku_yueka` | ¥18.0 | 30 天 |
| 季度会员 | `huiku_jika` | ¥48.0 | 90 天 |
| 年度会员 | `huiku_nianka` | ¥168.0 | 365 天 |

*注意：虽然我已经在 App 端做了本地兜底配置，但为了保持数据同步，建议尽快更新后端数据库。*

## 5. 订阅群组

*   **Group ID**: `21792558`

## 6. 下一步操作

1.  **登录服务器**：SSH 登录到 `hk.xbjy123.com`。
2.  **更新环境变量**：找到后端服务的 `.env` 文件或配置中心，填入上述 Shared Secret 和 Key ID。
3.  **重启服务**：重启后端 API 服务以应用更改。
4.  **验证**：使用 TestFlight 或沙盒账号在 App 中进行购买测试。
