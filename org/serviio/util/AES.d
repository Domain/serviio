module org.serviio.util.AES;

public class AES
{
  private static int Nb;
  private static int Nk;
  private static int Nr;
  private static byte[][] w;
  private static int[] sbox = { 99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118, 202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21, 4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117, 9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132, 83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207, 208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168, 81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210, 205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115, 96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219, 224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121, 231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8, 186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138, 112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158, 225, 248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223, 140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22 };

  private static int[] inv_sbox = { 82, 9, 106, 213, 48, 54, 165, 56, 191, 64, 163, 158, 129, 243, 215, 251, 124, 227, 57, 130, 155, 47, 255, 135, 52, 142, 67, 68, 196, 222, 233, 203, 84, 123, 148, 50, 166, 194, 35, 61, 238, 76, 149, 11, 66, 250, 195, 78, 8, 46, 161, 102, 40, 217, 36, 178, 118, 91, 162, 73, 109, 139, 209, 37, 114, 248, 246, 100, 134, 104, 152, 22, 212, 164, 92, 204, 93, 101, 182, 146, 108, 112, 72, 80, 253, 237, 185, 218, 94, 21, 70, 87, 167, 141, 157, 132, 144, 216, 171, 0, 140, 188, 211, 10, 247, 228, 88, 5, 184, 179, 69, 6, 208, 44, 30, 143, 202, 63, 15, 2, 193, 175, 189, 3, 1, 19, 138, 107, 58, 145, 17, 65, 79, 103, 220, 234, 151, 242, 207, 206, 240, 180, 230, 115, 150, 172, 116, 34, 231, 173, 53, 133, 226, 249, 55, 232, 28, 117, 223, 110, 71, 241, 26, 113, 29, 41, 197, 137, 111, 183, 98, 14, 170, 24, 190, 27, 252, 86, 62, 75, 198, 210, 121, 32, 154, 219, 192, 254, 120, 205, 90, 244, 31, 221, 168, 51, 136, 7, 199, 49, 177, 18, 16, 89, 39, 128, 236, 95, 96, 81, 127, 169, 25, 181, 74, 13, 45, 229, 122, 159, 147, 201, 156, 239, 160, 224, 59, 77, 174, 42, 245, 176, 200, 235, 187, 60, 131, 83, 153, 97, 23, 43, 4, 126, 186, 119, 214, 38, 225, 105, 20, 99, 85, 33, 12, 125 };

  private static int[] Rcon = { 141, 1, 2, 4, 8, 16, 32, 64, 128, 27, 54, 108, 216, 171, 77, 154, 47, 94, 188, 99, 198, 151, 53, 106, 212, 179, 125, 250, 239, 197, 145, 57, 114, 228, 211, 189, 97, 194, 159, 37, 74, 148, 51, 102, 204, 131, 29, 58, 116, 232, 203, 141, 1, 2, 4, 8, 16, 32, 64, 128, 27, 54, 108, 216, 171, 77, 154, 47, 94, 188, 99, 198, 151, 53, 106, 212, 179, 125, 250, 239, 197, 145, 57, 114, 228, 211, 189, 97, 194, 159, 37, 74, 148, 51, 102, 204, 131, 29, 58, 116, 232, 203, 141, 1, 2, 4, 8, 16, 32, 64, 128, 27, 54, 108, 216, 171, 77, 154, 47, 94, 188, 99, 198, 151, 53, 106, 212, 179, 125, 250, 239, 197, 145, 57, 114, 228, 211, 189, 97, 194, 159, 37, 74, 148, 51, 102, 204, 131, 29, 58, 116, 232, 203, 141, 1, 2, 4, 8, 16, 32, 64, 128, 27, 54, 108, 216, 171, 77, 154, 47, 94, 188, 99, 198, 151, 53, 106, 212, 179, 125, 250, 239, 197, 145, 57, 114, 228, 211, 189, 97, 194, 159, 37, 74, 148, 51, 102, 204, 131, 29, 58, 116, 232, 203, 141, 1, 2, 4, 8, 16, 32, 64, 128, 27, 54, 108, 216, 171, 77, 154, 47, 94, 188, 99, 198, 151, 53, 106, 212, 179, 125, 250, 239, 197, 145, 57, 114, 228, 211, 189, 97, 194, 159, 37, 74, 148, 51, 102, 204, 131, 29, 58, 116, 232, 203 };

  private static byte[] xor_func(byte[] a, byte[] b)
  {
    byte[] out_ = new byte[a.length];
    for (int i = 0; i < a.length; i++) {
      out_[i] = (cast(byte)(a[i] ^ b[i]));
    }
    return out_;
  }

  private static byte[][] generateSubkeys(byte[] key)
  {
    byte[][] tmp = new byte[Nb * (Nr + 1)][4];

    int i = 0;
    while (i < Nk)
    {
      tmp[i][0] = key[(i * 4)];
      tmp[i][1] = key[(i * 4 + 1)];
      tmp[i][2] = key[(i * 4 + 2)];
      tmp[i][3] = key[(i * 4 + 3)];
      i++;
    }
    i = Nk;
    while (i < Nb * (Nr + 1)) {
      byte[] temp = new byte[4];
      for (int k = 0; k < 4; k++)
        temp[k] = tmp[(i - 1)][k];
      if (i % Nk == 0) {
        temp = SubWord(rotateWord(temp));
        temp[0] = (cast(byte)(temp[0] ^ Rcon[(i / Nk)] & 0xFF));
      } else if ((Nk > 6) && (i % Nk == 4)) {
        temp = SubWord(temp);
      }
      tmp[i] = xor_func(tmp[(i - Nk)], temp);
      i++;
    }

    return tmp;
  }

  private static byte[] SubWord(byte[] in_) {
    byte[] tmp = new byte[in_.length];

    for (int i = 0; i < tmp.length; i++) {
      tmp[i] = (cast(byte)(sbox[(in_[i] & 0xFF)] & 0xFF));
    }
    return tmp;
  }

  private static byte[] rotateWord(byte[] input) {
    byte[] tmp = new byte[input.length];
    tmp[0] = input[1];
    tmp[1] = input[2];
    tmp[2] = input[3];
    tmp[3] = input[0];

    return tmp;
  }

  private static byte[][] AddRoundKey(byte[][] state, byte[][] w, int round)
  {
    byte[][] tmp = new byte[state.length][state[0].length];

    for (int c = 0; c < Nb; c++) {
      for (int l = 0; l < 4; l++) {
        tmp[l][c] = (cast(byte)(state[l][c] ^ w[(round * Nb + c)][l]));
      }
    }
    return tmp;
  }

  private static byte[][] SubBytes(byte[][] state)
  {
    byte[][] tmp = new byte[state.length][state[0].length];
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < Nb; col++)
        tmp[row][col] = (cast(byte)(sbox[(state[row][col] & 0xFF)] & 0xFF));
    }
    return tmp;
  }
  private static byte[][] InvSubBytes(byte[][] state) {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < Nb; col++)
        state[row][col] = (cast(byte)(inv_sbox[(state[row][col] & 0xFF)] & 0xFF));
    }
    return state;
  }

  private static byte[][] ShiftRows(byte[][] state)
  {
    byte[] t = new byte[4];
    for (int r = 1; r < 4; r++) {
      for (int c = 0; c < Nb; c++)
        t[c] = state[r][((c + r) % Nb)];
      for (int c = 0; c < Nb; c++) {
        state[r][c] = t[c];
      }
    }
    return state;
  }

  private static byte[][] InvShiftRows(byte[][] state) {
    byte[] t = new byte[4];
    for (int r = 1; r < 4; r++) {
      for (int c = 0; c < Nb; c++)
        t[((c + r) % Nb)] = state[r][c];
      for (int c = 0; c < Nb; c++)
        state[r][c] = t[c];
    }
    return state;
  }

  private static byte[][] InvMixColumns(byte[][] s) {
    int[] sp = new int[4];
    byte b02 = 14; byte b03 = 11; byte b04 = 13; byte b05 = 9;
    for (int c = 0; c < 4; c++) {
      sp[0] = (FFMul(b02, s[0][c]) ^ FFMul(b03, s[1][c]) ^ FFMul(b04, s[2][c]) ^ FFMul(b05, s[3][c]));
      sp[1] = (FFMul(b05, s[0][c]) ^ FFMul(b02, s[1][c]) ^ FFMul(b03, s[2][c]) ^ FFMul(b04, s[3][c]));
      sp[2] = (FFMul(b04, s[0][c]) ^ FFMul(b05, s[1][c]) ^ FFMul(b02, s[2][c]) ^ FFMul(b03, s[3][c]));
      sp[3] = (FFMul(b03, s[0][c]) ^ FFMul(b04, s[1][c]) ^ FFMul(b05, s[2][c]) ^ FFMul(b02, s[3][c]));
      for (int i = 0; i < 4; i++) s[i][c] = (cast(byte)sp[i]);
    }

    return s;
  }

  private static byte[][] MixColumns(byte[][] s) {
    int[] sp = new int[4];
    byte b02 = 2; byte b03 = 3;
    for (int c = 0; c < 4; c++) {
      sp[0] = (FFMul(b02, s[0][c]) ^ FFMul(b03, s[1][c]) ^ s[2][c] ^ s[3][c]);
      sp[1] = (s[0][c] ^ FFMul(b02, s[1][c]) ^ FFMul(b03, s[2][c]) ^ s[3][c]);
      sp[2] = (s[0][c] ^ s[1][c] ^ FFMul(b02, s[2][c]) ^ FFMul(b03, s[3][c]));
      sp[3] = (FFMul(b03, s[0][c]) ^ s[1][c] ^ s[2][c] ^ FFMul(b02, s[3][c]));
      for (int i = 0; i < 4; i++) s[i][c] = (cast(byte)sp[i]);
    }

    return s;
  }

  public static byte FFMul(byte a, byte b) {
    byte aa = a; byte bb = b; byte r = 0;
    while (aa != 0) {
      if ((aa & 0x1) != 0)
        r = cast(byte)(r ^ bb);
      byte t = cast(byte)(bb & 0x80);
      bb = cast(byte)(bb << 1);
      if (t != 0)
        bb = cast(byte)(bb ^ 0x1B);
      aa = cast(byte)((aa & 0xFF) >> 1);
    }
    return r;
  }

  public static byte[] encryptBloc(byte[] in_) {
    byte[] tmp = new byte[in_.length];

    byte[][] state = new byte[4][Nb];

    for (int i = 0; i < in_.length; i++) {
      state[(i / 4)][(i % 4)] = in_[(i % 4 * 4 + i / 4)];
    }
    state = AddRoundKey(state, w, 0);
    for (int round = 1; round < Nr; round++) {
      state = SubBytes(state);
      state = ShiftRows(state);
      state = MixColumns(state);
      state = AddRoundKey(state, w, round);
    }
    state = SubBytes(state);
    state = ShiftRows(state);
    state = AddRoundKey(state, w, Nr);

    for (int i = 0; i < tmp.length; i++) {
      tmp[(i % 4 * 4 + i / 4)] = state[(i / 4)][(i % 4)];
    }
    return tmp;
  }

  public static byte[] decryptBloc(byte[] in_) {
    byte[] tmp = new byte[in_.length];

    byte[][] state = new byte[4][Nb];

    for (int i = 0; i < in_.length; i++) {
      state[(i / 4)][(i % 4)] = in_[(i % 4 * 4 + i / 4)];
    }
    state = AddRoundKey(state, w, Nr);
    for (int round = Nr - 1; round >= 1; round--) {
      state = InvSubBytes(state);
      state = InvShiftRows(state);
      state = AddRoundKey(state, w, round);
      state = InvMixColumns(state);
    }

    state = InvSubBytes(state);
    state = InvShiftRows(state);
    state = AddRoundKey(state, w, 0);

    for (int i = 0; i < tmp.length; i++) {
      tmp[(i % 4 * 4 + i / 4)] = state[(i / 4)][(i % 4)];
    }
    return tmp;
  }

  public static byte[] encrypt(byte[] in_, byte[] key)
  {
    Nb = 4;
    Nk = key.length / 4;
    Nr = Nk + 6;

    int lenght = 0;
    byte[] padding = new byte[1];

    lenght = 16 - in_.length % 16;
    padding = new byte[lenght];
    padding[0] = -128;

    for (int i = 1; i < lenght; i++) {
      padding[i] = 0;
    }
    byte[] tmp = new byte[in_.length + lenght];
    byte[] bloc = new byte[16];

    w = generateSubkeys(key);

    int count = 0;

	for (int i = 0; i < in_.length + lenght; i++) {
      if ((i > 0) && (i % 16 == 0)) {
        bloc = encryptBloc(bloc);
        System.arraycopy(bloc, 0, tmp, i - 16, bloc.length);
      }
      if (i < in_.length) {
        bloc[(i % 16)] = in_[i];
      } else {
        bloc[(i % 16)] = padding[(count % 16)];
        count++;
      }
    }
	/// FIXME:
    /*if (bloc.length == 16) {
      bloc = encryptBloc(bloc);
      System.arraycopy(bloc, 0, tmp, i - 16, bloc.length);
    }*/

    return tmp;
  }

  public static byte[] decrypt(byte[] in_, byte[] key)
  {
    byte[] tmp = new byte[in_.length];
    byte[] bloc = new byte[16];

    Nb = 4;
    Nk = key.length / 4;
    Nr = Nk + 6;
    w = generateSubkeys(key);

    for (int i = 0; i < in_.length; i++) {
      if ((i > 0) && (i % 16 == 0)) {
        bloc = decryptBloc(bloc);
        System.arraycopy(bloc, 0, tmp, i - 16, bloc.length);
      }
      if (i < in_.length)
        bloc[(i % 16)] = in_[i];
    }
    /// FIXME:
    /*bloc = decryptBloc(bloc);
    System.arraycopy(bloc, 0, tmp, i - 16, bloc.length);*/

    tmp = deletePadding(tmp);

    return tmp;
  }

  private static byte[] deletePadding(byte[] input) {
    int count = 0;

    int i = input.length - 1;
    while (input[i] == 0) {
      count++;
      i--;
    }

    byte[] tmp = new byte[input.length - count - 1];
    System.arraycopy(input, 0, tmp, 0, tmp.length);
    return tmp;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.AES
 * JD-Core Version:    0.6.2
 */