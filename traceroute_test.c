
#include <traceroute.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

const char *addr2str (const sockaddr_any *addr)
{
	static char* leserver = "leserver";
	return leserver;
}
uint16_t in_csum (const void *ptr, size_t len)
{
	return (uint16_t) ~0;
}
int main() {
	probe pb = { .ext=0 };
	char buf1[] = { 0x20,0x00,0xad,0xbc,0x00,0x0c,0x01,0x01,0x00,0x31,0xc0,0x01,0x00,0x01,0x71,0x02 };
	handle_extensions(&pb, buf1, 16, 0);
	assert(pb.ext);
	assert(0 == strcmp(pb.ext, "MPLS:L=796,E=0,S=0,T=1/L=23,E=0,S=1,T=2"));
	free(pb.ext);

	char buf2[] = { 0x20,0x00,0xa9,0x42,0x00,0x60,0x02,0x0f,0x00,0x00,0x01,0x4c,0x00,0x02,0x00,0x00,0xfd,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,/*0x0a*/ 64,0x67,0x65,0x2d,0x30,0x2f,0x30,0x2f,0x30,0x2e,0x30,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,/* */0, 0, 0, /*0xdc,0x05,0x00,0x00*/ 0, 0, 5, 0xdc};
	pb.ext = 0;
	handle_extensions(&pb, buf2, 97 + 3, 0);
	assert(pb.ext);
	assert(0 == strcmp(pb.ext, "INC:332,leserver,\"ge-0/0/0.0\",mtu=1500"));
	free(pb.ext);

	char buf3[] = {0x20,0x00,0xbf,0x7d,0x00,0x54,0x02,0x0f,0x00,0x00,0x01,0x4c,0x00,0x01,0x00,0x00,0xc0,0xa8,0x50,0x02,/* 0x0a */ 64, 0x67,0x65,0x2d,0x30,0x2f,0x30,0x2f,0x30,0x2e,0x30,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,/*0xdc,0x05,0x00,0x00*/ 0, 0, 5, 0xdc};
	pb.ext = 0;
	handle_extensions(&pb, buf3, 88, 0);
	assert(pb.ext);
	assert(0 == strcmp(pb.ext, "INC:332,leserver,\"ge-0/0/0.0\",mtu=1500"));
	free(pb.ext);
	return 0;
}
