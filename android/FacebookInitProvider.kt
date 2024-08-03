package com.ma.delivery

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import com.facebook.FacebookSdk

class FacebookInitProvider : ContentProvider() {
    override fun onCreate(): Boolean {
        FacebookSdk.sdkInitialize(context)
        return false
    }

    // Implement other required methods (return null or false as they're not used)
    override fun query(uri: Uri, projection: Array<String>?, selection: String?, selectionArgs: Array<String>?, sortOrder: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?): Int = 0
}