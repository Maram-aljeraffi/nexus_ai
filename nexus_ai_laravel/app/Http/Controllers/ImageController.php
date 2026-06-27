<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ImageController extends Controller
{
    public function upload(Request $request)
    {
        // التحقق من صحة الملف
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
            'type' => 'required|string|in:profile,cover'
        ]);

        // تحديد المجلد حسب النوع
        $folder = $request->type === 'profile' ? 'profiles' : 'covers';
        
        // حفظ الصورة
        $path = $request->file('image')->store($folder, 'public');
        
        // رابط الصورة الكامل
        $url = asset('storage/' . $path);
        
        return response()->json([
            'success' => true,
            'url' => $url,
            'message' => 'تم رفع الصورة بنجاح'
        ]);
    }
}