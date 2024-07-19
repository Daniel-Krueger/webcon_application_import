using System;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.ActionPlugins;
using WebCon.WorkFlow.SDK.ActionPlugins.Model;
using WebCon.WorkFlow.SDK.Documents;
using WebCon.WorkFlow.SDK.Tools.Log;
using static System.Net.Mime.MediaTypeNames;

namespace BPS_Actions
{
    public class UploadPackageToImportSession : CustomAction<UploadPackageToImportSessionConfig>
    {
        IndentTextLogger logger;
        public override async Task RunAsync(RunCustomActionParams args)
        {

            logger = new IndentTextLogger(args.Context);
            try
            {

                if (!int.TryParse(Configuration.AttachmentId, out int attachmentId))
                {
                    throw new ArgumentException($"Parameter 'attachment id' with value '{Configuration.AttachmentId}' could not be parsed to int.");
                }
                var attachment = await args.Context.CurrentDocument.Attachments.GetByIDAsync(attachmentId);

                var content = await attachment.GetContentAsync();

                using (System.IO.Stream stream = new MemoryStream(content))
                using (HttpContent httpContent = new StreamContent(stream))
                {
                    logger.Log($"Attachment {attachment.FileName}({attachmentId}) should be uploaded using uri '{Configuration.APIEndpoint}'");
                    MultipartFormDataContent body = new MultipartFormDataContent { { httpContent, "File", "Package" } };
                    Uri uri = new Uri(Configuration.APIEndpoint);
                    var httpClient = new HttpClient();
                    httpClient.BaseAddress = uri;
                    httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", Configuration.AccesssToken);
                    HttpResponseMessage response = await httpClient.PostAsync(uri, body);
                    string json = await response.Content.ReadAsStringAsync();
                    if (!response.IsSuccessStatusCode)
                    {
                        logger.Log("Response content: " + response.Content);
                        throw new ApplicationException($"Uploading of attachment failed Status code'{response.StatusCode}'.");
                    }
                }
            }
            catch (System.Exception ex)
            {
                logger.Log("Executing UploadPackageToImportSession", ex, args.Context.CurrentDocument.ID);
                // HasErrors property is responsible for detection whether action has been executed properly or not. When set to "true"
                // whole path transition will be marked as faulted and all the actions on it will be rollbacked. User will be notified
                // about failure by display of error window.
                args.HasErrors = true;
                // Message property is responsible for error message content.
                args.Message = ex.Message;
            }
            finally
            {
                args.LogMessage = logger.ToString();
                logger.Dispose();
            }
            return;
        }
    }
}