package com.formbricks.formbrickssdk.webview

import android.annotation.SuppressLint
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Base64
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.ConsoleMessage
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.viewModels
import com.formbricks.formbrickssdk.Formbricks
import com.formbricks.formbrickssdk.databinding.FragmentFormbricksBinding
import com.formbricks.formbrickssdk.helper.mapToJsonElement
import com.formbricks.formbrickssdk.manager.FileUploadListener
import com.formbricks.formbrickssdk.manager.SurveyManager
import com.formbricks.formbrickssdk.model.javascript.FileData
import com.formbricks.formbrickssdk.model.response.SurveyResponse
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import timber.log.Timber
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.time.Instant
import java.util.Date
import java.util.Timer
import java.util.TimerTask


class FormbricksFragment : BottomSheetDialogFragment() {

    private lateinit var binding: FragmentFormbricksBinding
    private lateinit var surveyId: String
    private val closeTimer = Timer()
    private val viewModel: FormbricksViewModel by viewModels()

    private var webAppInterface = WebAppInterface(object : WebAppInterface.WebAppCallback {
        override fun onClose() {
            dismiss()
        }

        override fun onFinished() {
            closeTimer.schedule(object: TimerTask() {
                override fun run() {
                    dismiss()
                }

            }, Date.from(Instant.now().plusSeconds(CLOSING_TIMEOUT_IN_SECONDS)))
        }

        override fun onDisplay() {
            SurveyManager.createNewDisplay(surveyId)
        }

        override fun onResponse(response: SurveyResponse?) {
            SurveyManager.postResponse(response, surveyId)
        }

        override fun onRetry() {
        }

        override fun onFileUpload(file: FileData, uploadId: String) {
            SurveyManager.uploadFile(file, surveyId, uploadId, object: FileUploadListener {
                override fun fileUploaded(url: String, uploadId: String) {
                    val map: MutableMap<String, Any> = mutableMapOf(
                        Pair("success", true),
                        Pair("url", url),
                        Pair("uploadId", uploadId),
                    )
                    binding.formbricksWebview.post {
                        val json = mapToJsonElement(map).toString()
                        binding.formbricksWebview.evaluateJavascript("""window.onFileUploadComplete($json)""") {
                        }
                    }
                }
            })
        }
    })

    companion object {
        private val TAG: String by lazy { FormbricksFragment::class.java.simpleName }

        fun show(childFragmentManager: FragmentManager, surveyId: String) {
            val fragment = FormbricksFragment()
            fragment.surveyId = surveyId
            fragment.show(childFragmentManager, TAG)
        }

        private const val FILECHOOSER_RESULTCODE: Int = 1
        private const val CLOSING_TIMEOUT_IN_SECONDS = 5L
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = FragmentFormbricksBinding.inflate(inflater).apply {
            lifecycleOwner = viewLifecycleOwner
        }
        binding.viewModel = viewModel

        return binding.root
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.formbricksWebview.let {

            if (Formbricks.loggingEnabled) {
                WebView.setWebContentsDebuggingEnabled(true)
            }

            it.webChromeClient = object : WebChromeClient() {
                override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                    consoleMessage?.let { cm ->
                        val log = "[CONSOLE:${cm.messageLevel()}] \"${cm.message()}\", source: ${cm.sourceId()} (${cm.lineNumber()})"
                        Timber.tag("Javascript message").d(log)
                    }
                    return super.onConsoleMessage(consoleMessage)
                }

                override fun onShowFileChooser(
                    webView: WebView?,
                    filePathCallback: ValueCallback<Array<Uri>>?,
                    fileChooserParams: FileChooserParams?
                ): Boolean {
                    val intent = Intent()
                        .setType("*/*")
                        .setAction(Intent.ACTION_GET_CONTENT)

                    startActivityForResult(Intent.createChooser(intent, "Select a file"), Companion.FILECHOOSER_RESULTCODE)
                    return super.onShowFileChooser(webView, filePathCallback, fileChooserParams)
                }
            }

            it.settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                loadWithOverviewMode = true
                useWideViewPort = true
            }

            it.addJavascriptInterface(webAppInterface, WebAppInterface.INTERFACE_NAME)
        }

        viewModel.loadHtml(surveyId)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {

        if (requestCode == Companion.FILECHOOSER_RESULTCODE) {
            if (intent == null || resultCode != RESULT_OK) {
                return
            }

            var resultArray: Array<Uri?>? = null
            val dataString = intent.dataString

            if (dataString != null) {
                resultArray = arrayOf(Uri.parse(dataString))

                resultArray.mapNotNull { it }.forEach { uri ->
                    val type = activity?.contentResolver?.getType(uri)
                    val fileName = Date().time.toString()

                    val base64 = "data:${type};base64,${uriToBase64(uri)}"
                    binding.formbricksWebview.evaluateJavascript("""window.onFileUpload({"name": "$fileName", "type":"$type", "base64":"$base64"})""") { result ->
                        print(result)
                    }
                }
            }
        }
    }

    private fun uriToBase64(uri: Uri): String? {
        return try {
            val inputStream: InputStream? = activity?.contentResolver?.openInputStream(uri)
            val outputStream = ByteArrayOutputStream()
            val buffer = ByteArray(1024)
            var bytesRead: Int

            while (inputStream?.read(buffer).also { bytesRead = it ?: -1 } != -1) {
                outputStream.write(buffer, 0, bytesRead)
            }

            inputStream?.close()
            outputStream.close()

            Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}

