<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('certificates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('name', 255);
            $table->string('issuer', 255);
            $table->date('issue_date');
            $table->date('expiry_date')->nullable();
            $table->string('credential_url', 255)->nullable();
            $table->string('image', 255)->nullable(); // ✅ حقل رفع صورة الشهادة
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('certificates');
    }
};