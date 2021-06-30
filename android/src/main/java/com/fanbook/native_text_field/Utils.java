package com.fanbook.native_text_field;

import android.content.Context;
import android.text.Editable;
import android.text.InputType;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import com.vdurmont.emoji.Emoji;
import com.vdurmont.emoji.EmojiManager;
import com.vdurmont.emoji.EmojiParser;

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

    public static int string2TextAlignment(String alignmentString, boolean multiLines) {
        int gravity = Gravity.LEFT;
        if ("TextAlign.right".equals(alignmentString)) {
            return Gravity.RIGHT;
        } else if ("TextAlign.center".equals(alignmentString)) {
            return Gravity.CENTER_HORIZONTAL;
        }
        return multiLines ? gravity : (gravity | Gravity.CENTER_VERTICAL);
    }

    public static int string2InputType(String inputTypeString, boolean multiLines) {
        int type = InputType.TYPE_CLASS_TEXT;
        if ("TextInputType.number".equals(inputTypeString)) {
            type = InputType.TYPE_CLASS_NUMBER;
        } else if ("TextInputType.phone".equals(inputTypeString)) {
            type = InputType.TYPE_CLASS_PHONE;
        } else if ("TextInputType.emailAddress".equals(inputTypeString)) {
            type = InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
        }
        return multiLines ? (type | InputType.TYPE_TEXT_FLAG_MULTI_LINE) : type;
    }

    public static int calculateInputLength(Editable s) {
        if (s == null || s.length() <= 0) return 0;
        String temp = s.toString();
        int emojiCount = EmojiParser.extractEmojis(temp).size();
        String resultWithoutEmojiString = EmojiParser.removeAllEmojis(temp).replaceAll("[\\ufe0f]", "");
//        Log.d("calculateInputLength", "emoji resultWithOutEmojiUnicode: " + convert(resultWithoutEmojiString));
        int ret = resultWithoutEmojiString.length() + emojiCount;
//        Log.d("calculateInputLength", "emojicount: " + emojiCount + "  totalLength:" + ret + "  resultWithoutEmojiString:" + resultWithoutEmojiString);
        return ret;
    }

    public static String convert(String string) {
        StringBuffer unicode = new StringBuffer();

        for (int i = 0; i < string.length(); i++) {
            // 取出每一个字符
            char c = string.charAt(i);

            // 转换为unicode
            unicode.append(String.format("\\u%04x", Integer.valueOf(c)));
        }

        return unicode.toString();
    }
}
