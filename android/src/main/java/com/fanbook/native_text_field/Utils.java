package com.fanbook.native_text_field;

import android.content.Context;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

public class Utils {
    public static int dip2px(Context context, float dipValue) {
        float m = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * m + 0.5f);
    }

    public static int px2dip(Context context, float pxValue) {
        float m = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / m + 0.5f);
    }

    public static void hideSoftKeyboard(Context context, View view) {
        InputMethodManager inputMethodManager = (InputMethodManager) context.getSystemService(context.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }

    // 这个height是文字占高比，非文字高度值
    public static void setTextLineHeight(TextView textView, float height) {
        if (height < 1) return;
        final int fontHeight = textView.getPaint().getFontMetricsInt(null);
        final float textHeight = textView.getTextSize();
        float lineHeight = height * textHeight;
        textView.setLineSpacing(lineHeight - fontHeight, 1f);
    }

    public static float getTextLineHeight(TextView textView, float height) {
        final float textHeight = textView.getTextSize();
        return height * textHeight;
    }

    public static int string2TextAlignment(String alignmentString) {
        int gravity = Gravity.LEFT;
        if ("TextAlign.right".equals(alignmentString)) {
            return Gravity.RIGHT;
        } else if ("TextAlign.center".equals(alignmentString)) {
            return Gravity.CENTER;
        }
        return gravity;
    }

    public static int string2InputType(String inputTypeString) {
        int type = InputType.TYPE_CLASS_PHONE;
        if ("TextInputType.number".equals(inputTypeString)) {
            return InputType.TYPE_CLASS_NUMBER;
        } else if ("TextInputType.phone".equals(inputTypeString)) {
            return InputType.TYPE_CLASS_PHONE;
        } else if ("TextInputType.emailAddress".equals(inputTypeString)) {
            return InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
        }
        return type;
    }
}
