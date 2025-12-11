<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Komentar extends Model
{
    protected $fillable = [
        'user_id',
        'berita_id',
        'isi_komentar',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function berita()
    {
        return $this->belongsTo(Berita::class);
    }
}