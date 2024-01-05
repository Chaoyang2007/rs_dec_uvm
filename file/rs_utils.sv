`ifndef RS_UTILS__SV
`define RS_UTILS__SV

class error_location;
    rand bit has_error;
    rand int num;
    rand int loc1, loc2;

    constraint c {
        has_error inside {0, 1};
        (has_error == 0) -> {num == 0;}
        (has_error == 1) -> {num dist {1:=30, 2:=60};}
        loc1 inside {[0:`FEC_BLOCK_SIZE-1]};
        loc2 inside {[0:`FEC_BLOCK_SIZE-1]};
        loc1 != loc2;
    }

    function new(int has_error = 1);
        this.has_error = has_error;
    endfunction // new()
endclass // error_location

class rs_utils;
    // Constructor
    function new();
    endfunction //new()

    // Function to calculate parity
    static function void calculate_par(bit[1551:0] data, bit has_error=0, ref bit [31:0] parity);
        bit [31:0] parity_temp;
        // Introduce error(s)
        error_location eloc;
        bit [7:0] edata1, edata2;
        bit [7:0] G0 = 64, G1 = 120, G2 = 54, G3 = 15;
        bit [7:0] R0 = 0, R1 = 0, R2 = 0, R3 = 0;
        bit [7:0] Rd, G0xRd, G1xRd, G2xRd, G3xRd;

        if (has_error) begin
            eloc = new();
            assert(eloc.randomize());
            edata1 = data[1551 - 8 * eloc.loc1 -: 8];
            data[1551 - 8 * eloc.loc1 -: 8] = 8'b0;

            if (eloc.num == 2) begin
                edata2 = data[1551 - 8 * eloc.loc2 -: 8];
                data[1551 - 8 * eloc.loc2 -: 8] = 8'b0;
            end

            if (eloc.num == 1) begin
                `uvm_info("calculating parities", $sformatf("1 error, (loc, val)=(%0d, %0h).", eloc.loc1, edata1), UVM_MEDIUM);
            end else begin
                `uvm_info("calculating parities", $sformatf("2 errors, (loc1, val1)=(%0d, %0h), (loc2, val2)=(%0d, %0h).", eloc.loc1, edata1, eloc.loc2, edata2), UVM_MEDIUM);
            end
        end else begin
            `uvm_info("calculating parities", $sformatf("0 error, (loc, val)=(x, x)."), UVM_MEDIUM);
        end

        // Calculate parities
        for (integer i = 0; i < `FEC_BLOCK_SIZE; i++) begin
            Rd = R3 ^ data[1551 - 8 * i -: 8];
            gf2m8_multi(Rd, G0, G0xRd);
            gf2m8_multi(Rd, G1, G1xRd);
            gf2m8_multi(Rd, G2, G2xRd);
            gf2m8_multi(Rd, G3, G3xRd);
            R3 = G3xRd ^ R2;
            R2 = G2xRd ^ R1;
            R1 = G1xRd ^ R0;
            R0 = G0xRd;
            parity_temp = {parity_temp[23:0], R3};
        end
        `uvm_info("calculating parities", $sformatf("parity bytes %0h.", parity_temp), UVM_MEDIUM);
        parity = parity_temp;
    endfunction // calculate_par

    // Function to multiply two 8-bit numbers in GF(2^8)
    static function void gf2m8_multi(bit[7:0] x, bit[7:0] y, ref bit [7:0] z);
        z[0] = ^{ y[0] & x[0], 
                        y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                        y[5] & x[7], y[6] & x[6], y[7] & x[5], //5-7
                        y[6] & x[7], y[7] & x[6], //6-7
                        y[7] & x[7] }; //7
        z[1] = ^{ y[0] & x[1], y[1] & x[0], 
                        y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2], //2-7
                        y[6] & x[7], y[7] & x[6], //6-7
                        y[7] & x[7] }; //7
        z[2] = ^{ y[0] & x[2], y[1] & x[1], y[2] & x[0], 
                        y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                        y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3], //3-7
                        y[5] & x[7], y[6] & x[6], y[7] & x[5], //5-7
                        y[6] & x[7], y[7] & x[6] }; //6-7
        z[3] = ^{ y[0] & x[3], y[1] & x[2], y[2] & x[1], y[3] & x[0], 
                        y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                        y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2], //2-7
                        y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4], //4-7
                        y[5] & x[7], y[6] & x[6], y[7] & x[5] }; //5-7
        z[4] = ^{ y[0] & x[4], y[1] & x[3], y[2] & x[2], y[3] & x[1], y[4] & x[0], 
                        y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                        y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2], //2-7
                        y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3], //3-7
                        y[7] & x[7] }; //7
        z[5] = ^{ y[0] & x[5], y[1] & x[4], y[2] & x[3], y[3] & x[2], y[4] & x[1], y[5] & x[0], 
                        y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2], //2-7
                        y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3], //3-7
                        y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4] }; //4-7
        z[6] = ^{ y[0] & x[6], y[1] & x[5], y[2] & x[4], y[3] & x[3], y[4] & x[2], y[5] & x[1], y[6] & x[0], 
                        y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3], //3-7
                        y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4], //4-7
                        y[5] & x[7], y[6] & x[6], y[7] & x[5] }; //5-7
        z[7] = ^{ y[0] & x[7], y[1] & x[6], y[2] & x[5], y[3] & x[4], y[4] & x[3], y[5] & x[2], y[6] & x[1], y[7] & x[0], 
                        y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4], //4-7
                        y[5] & x[7], y[6] & x[6], y[7] & x[5], //5-7
                        y[6] & x[7], y[7] & x[6] }; //6-7
    endfunction // gf2m8_multi

    // Function to divide two 8-bit numbers in GF(2^8)
    static function void gf2m8_divid(bit[7:0] dividend, bit[7:0] divisor, ref bit [7:0] quotient);
        bit [7:0] inv;
        case (divisor)
            8'd1:    inv = 8'd1;  // 2^255 2^0
            8'd2:    inv = 8'd142;  // 2^1
            8'd4:    inv = 8'd71;  // 2^2
            8'd8:    inv = 8'd173;  // 2^3
            8'd16:   inv = 8'd216;  // 2^4
            8'd32:   inv = 8'd108;  // 2^5
            8'd64:   inv = 8'd54;  // 2^6
            8'd128:  inv = 8'd27;  // 2^7
            8'd29:   inv = 8'd131;  // 2^8
            8'd58:   inv = 8'd207;  // 2^9
            8'd116:  inv = 8'd233;  // 2^10
            8'd232:  inv = 8'd250;  // 2^11
            8'd205:  inv = 8'd125;  // 2^12
            8'd135:  inv = 8'd176;  // 2^13
            8'd19:   inv = 8'd88;  // 2^14
            8'd38:   inv = 8'd44;  // 2^15
            8'd76:   inv = 8'd22;  // 2^16
            8'd152:  inv = 8'd11;  // 2^17
            8'd45:   inv = 8'd139;  // 2^18
            8'd90:   inv = 8'd203;  // 2^19
            8'd180:  inv = 8'd235;  // 2^20
            8'd117:  inv = 8'd251;  // 2^21
            8'd234:  inv = 8'd243;  // 2^22
            8'd201:  inv = 8'd247;  // 2^23
            8'd143:  inv = 8'd245;  // 2^24
            8'd3:    inv = 8'd244;  // 2^25
            8'd6:    inv = 8'd122;  // 2^26
            8'd12:   inv = 8'd61;  // 2^27
            8'd24:   inv = 8'd144;  // 2^28
            8'd48:   inv = 8'd72;  // 2^29
            8'd96:   inv = 8'd36;  // 2^30
            8'd192:  inv = 8'd18;  // 2^31
            8'd157:  inv = 8'd9;  // 2^32
            8'd39:   inv = 8'd138;  // 2^33
            8'd78:   inv = 8'd69;  // 2^34
            8'd156:  inv = 8'd172;  // 2^35
            8'd37:   inv = 8'd86;  // 2^36
            8'd74:   inv = 8'd43;  // 2^37
            8'd148:  inv = 8'd155;  // 2^38
            8'd53:   inv = 8'd195;  // 2^39
            8'd106:  inv = 8'd239;  // 2^40
            8'd212:  inv = 8'd249;  // 2^41
            8'd181:  inv = 8'd242;  // 2^42
            8'd119:  inv = 8'd121;  // 2^43
            8'd238:  inv = 8'd178;  // 2^44
            8'd193:  inv = 8'd89;  // 2^45
            8'd159:  inv = 8'd162;  // 2^46
            8'd35:   inv = 8'd81;  // 2^47
            8'd70:   inv = 8'd166;  // 2^48
            8'd140:  inv = 8'd83;  // 2^49
            8'd5:    inv = 8'd167;  // 2^50
            8'd10:   inv = 8'd221;  // 2^51
            8'd20:   inv = 8'd224;  // 2^52
            8'd40:   inv = 8'd112;  // 2^53
            8'd80:   inv = 8'd56;  // 2^54
            8'd160:  inv = 8'd28;  // 2^55
            8'd93:   inv = 8'd14;  // 2^56
            8'd186:  inv = 8'd7;  // 2^57
            8'd105:  inv = 8'd141;  // 2^58
            8'd210:  inv = 8'd200;  // 2^59
            8'd185:  inv = 8'd100;  // 2^60
            8'd111:  inv = 8'd50;  // 2^61
            8'd222:  inv = 8'd25;  // 2^62
            8'd161:  inv = 8'd130;  // 2^63
            8'd95:   inv = 8'd65;  // 2^64
            8'd190:  inv = 8'd174;  // 2^65
            8'd97:   inv = 8'd87;  // 2^66
            8'd194:  inv = 8'd165;  // 2^67
            8'd153:  inv = 8'd220;  // 2^68
            8'd47:   inv = 8'd110;  // 2^69
            8'd94:   inv = 8'd55;  // 2^70
            8'd188:  inv = 8'd149;  // 2^71
            8'd101:  inv = 8'd196;  // 2^72
            8'd202:  inv = 8'd98;  // 2^73
            8'd137:  inv = 8'd49;  // 2^74
            8'd15:   inv = 8'd150;  // 2^75
            8'd30:   inv = 8'd75;  // 2^76
            8'd60:   inv = 8'd171;  // 2^77
            8'd120:  inv = 8'd219;  // 2^78
            8'd240:  inv = 8'd227;  // 2^79
            8'd253:  inv = 8'd255;  // 2^80
            8'd231:  inv = 8'd241;  // 2^81
            8'd211:  inv = 8'd246;  // 2^82
            8'd187:  inv = 8'd123;  // 2^83
            8'd107:  inv = 8'd179;  // 2^84
            8'd214:  inv = 8'd215;  // 2^85
            8'd177:  inv = 8'd229;  // 2^86
            8'd127:  inv = 8'd252;  // 2^87
            8'd254:  inv = 8'd126;  // 2^88
            8'd225:  inv = 8'd63;  // 2^89
            8'd223:  inv = 8'd145;  // 2^90
            8'd163:  inv = 8'd198;  // 2^91
            8'd91:   inv = 8'd99;  // 2^92
            8'd182:  inv = 8'd191;  // 2^93
            8'd113:  inv = 8'd209;  // 2^94
            8'd226:  inv = 8'd230;  // 2^95
            8'd217:  inv = 8'd115;  // 2^96
            8'd175:  inv = 8'd183;  // 2^97
            8'd67:   inv = 8'd213;  // 2^98
            8'd134:  inv = 8'd228;  // 2^99
            8'd17:   inv = 8'd114;  // 2^100
            8'd34:   inv = 8'd57;  // 2^101
            8'd68:   inv = 8'd146;  // 2^102
            8'd136:  inv = 8'd73;  // 2^103
            8'd13:   inv = 8'd170;  // 2^104
            8'd26:   inv = 8'd85;  // 2^105
            8'd52:   inv = 8'd164;  // 2^106
            8'd104:  inv = 8'd82;  // 2^107
            8'd208:  inv = 8'd41;  // 2^108
            8'd189:  inv = 8'd154;  // 2^109
            8'd103:  inv = 8'd77;  // 2^110
            8'd206:  inv = 8'd168;  // 2^111
            8'd129:  inv = 8'd84;  // 2^112
            8'd31:   inv = 8'd42;  // 2^113
            8'd62:   inv = 8'd21;  // 2^114
            8'd124:  inv = 8'd132;  // 2^115
            8'd248:  inv = 8'd66;  // 2^116
            8'd237:  inv = 8'd33;  // 2^117
            8'd199:  inv = 8'd158;  // 2^118
            8'd147:  inv = 8'd79;  // 2^119
            8'd59:   inv = 8'd169;  // 2^120
            8'd118:  inv = 8'd218;  // 2^121
            8'd236:  inv = 8'd109;  // 2^122
            8'd197:  inv = 8'd184;  // 2^123
            8'd151:  inv = 8'd92;  // 2^124
            8'd51:   inv = 8'd46;  // 2^125
            8'd102:  inv = 8'd23;  // 2^126
            8'd204:  inv = 8'd133;  // 2^127
            8'd133:  inv = 8'd204;  // 2^128
            8'd23:   inv = 8'd102;  // 2^129
            8'd46:   inv = 8'd51;  // 2^130
            8'd92:   inv = 8'd151;  // 2^131
            8'd184:  inv = 8'd197;  // 2^132
            8'd109:  inv = 8'd236;  // 2^133
            8'd218:  inv = 8'd118;  // 2^134
            8'd169:  inv = 8'd59;  // 2^135
            8'd79:   inv = 8'd147;  // 2^136
            8'd158:  inv = 8'd199;  // 2^137
            8'd33:   inv = 8'd237;  // 2^138
            8'd66:   inv = 8'd248;  // 2^139
            8'd132:  inv = 8'd124;  // 2^140
            8'd21:   inv = 8'd62;  // 2^141
            8'd42:   inv = 8'd31;  // 2^142
            8'd84:   inv = 8'd129;  // 2^143
            8'd168:  inv = 8'd206;  // 2^144
            8'd77:   inv = 8'd103;  // 2^145
            8'd154:  inv = 8'd189;  // 2^146
            8'd41:   inv = 8'd208;  // 2^147
            8'd82:   inv = 8'd104;  // 2^148
            8'd164:  inv = 8'd52;  // 2^149
            8'd85:   inv = 8'd26;  // 2^150
            8'd170:  inv = 8'd13;  // 2^151
            8'd73:   inv = 8'd136;  // 2^152
            8'd146:  inv = 8'd68;  // 2^153
            8'd57:   inv = 8'd34;  // 2^154
            8'd114:  inv = 8'd17;  // 2^155
            8'd228:  inv = 8'd134;  // 2^156
            8'd213:  inv = 8'd67;  // 2^157
            8'd183:  inv = 8'd175;  // 2^158
            8'd115:  inv = 8'd217;  // 2^159
            8'd230:  inv = 8'd226;  // 2^160
            8'd209:  inv = 8'd113;  // 2^161
            8'd191:  inv = 8'd182;  // 2^162
            8'd99:   inv = 8'd91;  // 2^163
            8'd198:  inv = 8'd163;  // 2^164
            8'd145:  inv = 8'd223;  // 2^165
            8'd63:   inv = 8'd225;  // 2^166
            8'd126:  inv = 8'd254;  // 2^167
            8'd252:  inv = 8'd127;  // 2^168
            8'd229:  inv = 8'd177;  // 2^169
            8'd215:  inv = 8'd214;  // 2^170
            8'd179:  inv = 8'd107;  // 2^171
            8'd123:  inv = 8'd187;  // 2^172
            8'd246:  inv = 8'd211;  // 2^173
            8'd241:  inv = 8'd231;  // 2^174
            8'd255:  inv = 8'd253;  // 2^175
            8'd227:  inv = 8'd240;  // 2^176
            8'd219:  inv = 8'd120;  // 2^177
            8'd171:  inv = 8'd60;  // 2^178
            8'd75:   inv = 8'd30;  // 2^179
            8'd150:  inv = 8'd15;  // 2^180
            8'd49:   inv = 8'd137;  // 2^181
            8'd98:   inv = 8'd202;  // 2^182
            8'd196:  inv = 8'd101;  // 2^183
            8'd149:  inv = 8'd188;  // 2^184
            8'd55:   inv = 8'd94;  // 2^185
            8'd110:  inv = 8'd47;  // 2^186
            8'd220:  inv = 8'd153;  // 2^187
            8'd165:  inv = 8'd194;  // 2^188
            8'd87:   inv = 8'd97;  // 2^189
            8'd174:  inv = 8'd190;  // 2^190
            8'd65:   inv = 8'd95;  // 2^191
            8'd130:  inv = 8'd161;  // 2^192
            8'd25:   inv = 8'd222;  // 2^193
            8'd50:   inv = 8'd111;  // 2^194
            8'd100:  inv = 8'd185;  // 2^195
            8'd200:  inv = 8'd210;  // 2^196
            8'd141:  inv = 8'd105;  // 2^197
            8'd7:    inv = 8'd186;  // 2^198
            8'd14:   inv = 8'd93;  // 2^199
            8'd28:   inv = 8'd160;  // 2^200
            8'd56:   inv = 8'd80;  // 2^201
            8'd112:  inv = 8'd40;  // 2^202
            8'd224:  inv = 8'd20;  // 2^203
            8'd221:  inv = 8'd10;  // 2^204
            8'd167:  inv = 8'd5;  // 2^205
            8'd83:   inv = 8'd140;  // 2^206
            8'd166:  inv = 8'd70;  // 2^207
            8'd81:   inv = 8'd35;  // 2^208
            8'd162:  inv = 8'd159;  // 2^209
            8'd89:   inv = 8'd193;  // 2^210
            8'd178:  inv = 8'd238;  // 2^211
            8'd121:  inv = 8'd119;  // 2^212
            8'd242:  inv = 8'd181;  // 2^213
            8'd249:  inv = 8'd212;  // 2^214
            8'd239:  inv = 8'd106;  // 2^215
            8'd195:  inv = 8'd53;  // 2^216
            8'd155:  inv = 8'd148;  // 2^217
            8'd43:   inv = 8'd74;  // 2^218
            8'd86:   inv = 8'd37;  // 2^219
            8'd172:  inv = 8'd156;  // 2^220
            8'd69:   inv = 8'd78;  // 2^221
            8'd138:  inv = 8'd39;  // 2^222
            8'd9:    inv = 8'd157;  // 2^223
            8'd18:   inv = 8'd192;  // 2^224
            8'd36:   inv = 8'd96;  // 2^225
            8'd72:   inv = 8'd48;  // 2^226
            8'd144:  inv = 8'd24;  // 2^227
            8'd61:   inv = 8'd12;  // 2^228
            8'd122:  inv = 8'd6;  // 2^229
            8'd244:  inv = 8'd3;  // 2^230
            8'd245:  inv = 8'd143;  // 2^231
            8'd247:  inv = 8'd201;  // 2^232
            8'd243:  inv = 8'd234;  // 2^233
            8'd251:  inv = 8'd117;  // 2^234
            8'd235:  inv = 8'd180;  // 2^235
            8'd203:  inv = 8'd90;  // 2^236
            8'd139:  inv = 8'd45;  // 2^237
            8'd11:   inv = 8'd152;  // 2^238
            8'd22:   inv = 8'd76;  // 2^239
            8'd44:   inv = 8'd38;  // 2^240
            8'd88:   inv = 8'd19;  // 2^241
            8'd176:  inv = 8'd135;  // 2^242
            8'd125:  inv = 8'd205;  // 2^243
            8'd250:  inv = 8'd232;  // 2^244
            8'd233:  inv = 8'd116;  // 2^245
            8'd207:  inv = 8'd58;  // 2^246
            8'd131:  inv = 8'd29;  // 2^247
            8'd27:   inv = 8'd128;  // 2^248
            8'd54:   inv = 8'd64;  // 2^249
            8'd108:  inv = 8'd32;  // 2^250
            8'd216:  inv = 8'd16;  // 2^251
            8'd173:  inv = 8'd8;  // 2^252
            8'd71:   inv = 8'd4;  // 2^253
            8'd142:  inv = 8'd2;  // 2^254
            default: inv = 8'd0;
        endcase
        gf2m8_multi(dividend, inv, quotient);
    endfunction // gf2m8_divid
endclass //rs_utils

`endif // RS_UTILS__SV
