using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

namespace BPS_Actions
{
    public class UploadPackageToImportSessionConfig : PluginConfiguration
    {
        [ConfigEditableText(DisplayName = "API Endpoint", Description = "The full API endpoint.", IsRequired = true,DefaultText = "https://BPSPORTAL.LOCAL/api/data/v6.0/db/DBID/importsessions/|sessionId|/1")]
        public string APIEndpoint{ get; set; }

        [ConfigEditableText(DisplayName = "Access token", Description = "The already retrieved access token.", IsRequired = true)]
        public string AccesssToken { get; set; }
                
        [ConfigEditableText(DisplayName = "Attachment id", Description = "Id of the attachment which should be uploaded.", IsRequired = true)]
        public string AttachmentId { get; set; }

    }
}