package com.formbricks.formbrickssdk.webview

import android.R
import android.annotation.SuppressLint
import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.viewModels
import com.formbricks.formbrickssdk.databinding.FragmentFormbricksBinding
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment


class FormbricksFragment : BottomSheetDialogFragment() {

    private lateinit var binding: FragmentFormbricksBinding

    companion object {
        private val TAG: String by lazy { FormbricksFragment::class.java.simpleName }

        fun show(childFragmentManager: FragmentManager) {
            val fragment = FormbricksFragment()
            fragment.show(childFragmentManager, TAG)
        }
    }

    private val viewModel: FormbricksViewModel by viewModels()

//    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
//        return BottomSheetDialog(requireContext(), com.formbricks.formbrickssdk.R.style.MyTransparentBottomSheetDialogTheme)
//    }

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
        binding.formbricksWebview.settings.javaScriptEnabled = true
        viewModel.loadHtml()
    }
}