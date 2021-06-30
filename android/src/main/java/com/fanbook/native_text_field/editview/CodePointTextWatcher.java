package com.fanbook.native_text_field.editview;

import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.widget.EditText;
import android.widget.TextView;

import com.fanbook.native_text_field.Utils;

public class CodePointTextWatcher implements TextWatcher {
    private static final String TAG = "CodePointTextWatcher";

    private final EditText editText;
    private final int maxLength;
    private String oldTextString = "";

    public CodePointTextWatcher(EditText editText, int maxLength) {
        this.editText = editText;
        this.maxLength = maxLength;

    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        oldTextString = s.toString();
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
//        Log.d(TAG, "onTextChanged: start:" + start + " before:" + before + " count:" + count);
    }

    @Override
    public void afterTextChanged(Editable s) {
        String newTextString = s.toString();
        if (newTextString.length() <= 0) return;
        if (newTextString.equals(oldTextString)) return;
        int len = Utils.calculateInputLength(s);
        if (len > maxLength) {
            newTextString = oldTextString;
            editText.setText(newTextString);
            editText.setSelection(newTextString.length());
        }
    }
}
