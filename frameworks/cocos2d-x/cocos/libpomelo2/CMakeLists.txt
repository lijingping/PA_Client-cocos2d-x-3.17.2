
include_directories(${COCOS2DX_ROOT_PATH}/cocos/libpomelo2/include)
include_directories(${COCOS2DX_ROOT_PATH}/cocos/libpomelo2/src)
include_directories(${COCOS2DX_ROOT_PATH}/cocos/libpomelo2/src/tr/dummy)
include_directories(${COCOS2DX_ROOT_PATH}/cocos/libpomelo2/src/tr/uv)

set(COCOS_LIBPOMELO2_HEADER

    libpomelo2/src/pc_JSON.h
    libpomelo2/src/pc_lib.h
    libpomelo2/src/pc_mutex.h
    libpomelo2/src/pc_pomelo_i.h
    libpomelo2/src/pc_trans_repo.h
    libpomelo2/src/queue.h
    libpomelo2/src/tr/dummy/tr_dummy.h
    libpomelo2/src/tr/uv/pb.h
    libpomelo2/src/tr/uv/pr_msg.h
    libpomelo2/src/tr/uv/pr_pkg.h
    libpomelo2/src/tr/uv/tr_uv_tcp_aux.h
    libpomelo2/src/tr/uv/tr_uv_tcp_i.h
    libpomelo2/src/tr/uv/tr_uv_tcp.h
    libpomelo2/src/tr/uv/tr_uv_tls_aux.h
    libpomelo2/src/tr/uv/tr_uv_tls_i.h
    libpomelo2/src/tr/uv/tr_uv_tls.h
	)

set(COCOS_LIBPOMELO2_SRC

    libpomelo2/src/pc_JSON.c
    libpomelo2/src/pc_lib.c
    libpomelo2/src/pc_pomelo.c
    libpomelo2/src/pc_trans.c
    libpomelo2/src/pc_trans_repo.c
    libpomelo2/src/tr/dummy/tr_dummy.c
    libpomelo2/src/tr/uv/pb_decode.c
    libpomelo2/src/tr/uv/pb_encode.c
    libpomelo2/src/tr/uv/pb_i.c
    libpomelo2/src/tr/uv/pr_msg.c
    libpomelo2/src/tr/uv/pr_msg_json.c
    libpomelo2/src/tr/uv/pr_msg_pb.c
    libpomelo2/src/tr/uv/pr_pkg.c
    libpomelo2/src/tr/uv/tr_uv_tcp.c
    libpomelo2/src/tr/uv/tr_uv_tcp_aux.c
    libpomelo2/src/tr/uv/tr_uv_tcp_i.c
    libpomelo2/src/tr/uv/tr_uv_tls.c
    libpomelo2/src/tr/uv/tr_uv_tls_aux.c
    libpomelo2/src/tr/uv/tr_uv_tls_i.c
    )

