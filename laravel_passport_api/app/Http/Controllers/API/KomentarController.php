<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Komentar;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class KomentarController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'berita_id' => 'required|exists:beritas,id',
            'isi_komentar' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $komentar = Komentar::create([
            'user_id' => $request->user()->id,
            'berita_id' => $request->berita_id,
            'isi_komentar' => $request->isi_komentar,
        ]);

        return response()->json([
            'message' => 'Komentar berhasil ditambahkan',
            'komentar' => $komentar->load('user')
        ], 201);
    }

    public function destroy(Request $request, $id)
    {
        $komentar = Komentar::find($id);

        if (!$komentar) {
            return response()->json(['message' => 'Komentar tidak ditemukan'], 404);
        }

        if ($komentar->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $komentar->delete();

        return response()->json(['message' => 'Komentar berhasil dihapus']);
    }
}