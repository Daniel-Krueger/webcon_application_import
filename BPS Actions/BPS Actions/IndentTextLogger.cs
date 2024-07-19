using System;
using System.IO;
using WebCon.WorkFlow.SDK.Common.Model;

namespace BPS_Actions
{

    public class IndentTextLogger : IDisposable
    {
        private readonly StringWriter stringWriter = new StringWriter();
        private System.CodeDom.Compiler.IndentedTextWriter indentWriter;
        private readonly BaseContext _context;
        public IndentTextLogger(BaseContext context, string indentationString = "\t")
        {
            _context = context;
            indentWriter = new System.CodeDom.Compiler.IndentedTextWriter(stringWriter, indentationString);
        }

        public void Indent()
        {
            indentWriter.Indent++;
        }

        public void Outdent()
        {
            indentWriter.Indent--;
        }

        public void Log(string message)
        {
            indentWriter.WriteLine(message);
        }

        public void Log(string message, Exception ex, int? workflowId)
        {
            indentWriter.Write(message);
            logException(ex);

            //(new WebCon.WorkFlow.SDK.Tools.Log.Logger(_context)).WriteToLog(new WebCon.WorkFlow.SDK.Tools.Log.WriteToLogParams()
            //{
            //    DocumentID = workflowId,
            //    EntryType = System.Diagnostics.EventLogEntryType.Error,
            //    Exception = ex,
            //    Message = message
            //});
        }
        private void logException(Exception ex)
        {
            indentWriter.Indent++;

            indentWriter.WriteLine($"Exception '{ex.GetType()}");
            indentWriter.WriteLine($"Message '{ex.Message}'");
            indentWriter.WriteLine($"Stack '{ex.StackTrace}'");
            if (ex.InnerException != null)
            {
                logException(ex.InnerException);
            }
            indentWriter.Indent--;

            if (this._context != null)
            {
                this._context.PluginLogger.AppendInfo($"Error occured:"+ this.ToString());

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns>Returns the logged messages.</returns>
        public override string ToString()
        {
            return stringWriter.ToString();
        }

        public void Dispose()
        {
            if (indentWriter != null)
            {
                indentWriter.Dispose();
            }
            if (stringWriter != null)
            {
                stringWriter.Dispose();
            }
        }
    }
}
