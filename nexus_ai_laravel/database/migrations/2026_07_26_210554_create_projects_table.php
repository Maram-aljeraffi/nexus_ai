<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('title', 255);
            $table->text('description');
            $table->jsonb('technologies')->nullable();
            $table->string('link', 255)->nullable();
            $table->string('image', 255)->nullable();
            $table->date('started_at')->nullable();
            $table->date('ended_at')->nullable()->check('ended_at >= started_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};