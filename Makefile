-include Makefile.local

##############################################################################
# Compile, link, and install flags

CPPFLAGS += -Iinclude/
CPPFLAGS += $(EXTRA_CPPFLAGS)
# CFLAGS += -std=gnu99 -O3 -g -Wall -Werror -march=native -fno-omit-frame-pointer
CFLAGS += -std=gnu99 -O3 -g -Wall -march=native -fno-omit-frame-pointer
CFLAGS += $(EXTRA_CFLAGS)
CFLAGS_SHARED += $(CFLAGS) -fPIC
LDFLAGS += -pthread -g
LDFLAGS += $(EXTRA_LDFLAGS)
LDLIBS += -lm -lpthread -lrt -ldl
# LDLIBS += -lm -lpthread -lrt
LDLIBS += $(EXTRA_LDLIBS)

PREFIX ?= /usr/local
SBINDIR ?= $(PREFIX)/sbin
LIBDIR ?= $(PREFIX)/lib
INCDIR ?= $(PREFIX)/include
EXTRA_LIBS_DPDK= -libverbs -lmlx5


##############################################################################
# DPDK configuration

# Prefix for dpdk
RTE_SDK ?= /home/alireza/dpdk-stable-19.11.14/build/install/usr/local
# mpdts to compile
DPDK_PMDS ?= netvsc

DPDK_CPPFLAGS += -I$(RTE_SDK)/include -I$(RTE_SDK)/include/dpdk \
  -I$(RTE_SDK)/include/x86_64-linux-gnu/dpdk/
DPDK_CFLAGS += -I$(RTE_SDK)/include -I$(RTE_SDK)/include/dpdk \
  -I$(RTE_SDK)/include/x86_64-linux-gnu/dpdk/
DPDK_LDFLAGS+= -L$(RTE_SDK)/lib/x86_64-linux-gnu
#-l:librte_pmd_netvsc.a 

DPDK_LDLIBS+= \
  -Wl,--whole-archive \
  $(addprefix -lrte_pmd_,$(DPDK_PMDS)) \
  -l:librte_pmd_mlx5.a \
  -l:librte_pmd_netvsc.a \
  -l:librte_eal.a \
  -l:librte_mempool.a \
  -l:librte_mempool_ring.a \
  -l:librte_hash.a \
  -l:librte_ring.a \
  -l:librte_kvargs.a \
  -l:librte_ethdev.a \
  -l:librte_mbuf.a \
  -l:librte_bus_pci.a \
  -l:librte_pci.a \
  -l:librte_cmdline.a \
  -l:librte_timer.a \
  -l:librte_kni.a \
  -l:librte_net.a \
  -l:librte_bus_vdev.a \
  -l:librte_gso.a \
  -l:librte_bus_vmbus.a \
  -Wl,--no-whole-archive \
  -lnuma \
  -ldl \
  $(EXTRA_LIBS_DPDK)
 


##############################################################################

include mk/recipes.mk

DEPS :=
CLEAN :=
DISTCLEAN :=
TARGETS :=

# Subdirectories

dir := lib
include $(dir)/rules.mk

dir := tas
include $(dir)/rules.mk

dir := tools
include $(dir)/rules.mk

dir := tests
include $(dir)/rules.mk

dir := doc
include $(dir)/rules.mk


##############################################################################
# Top level targets

all: $(TARGETS)

clean:
	rm -rf $(CLEAN) $(DEPS)

distclean:
	rm -rf $(DISTCLEAN) $(CLEAN) $(DEPS)

install: tas/tas lib/libtas_sockets.so lib/libtas_interpose.so \
  lib/libtas.so tools/statetool
	mkdir -p $(DESTDIR)$(SBINDIR)
	cp tas/tas $(DESTDIR)$(SBINDIR)/tas
	cp tools/statetool $(DESTDIR)$(SBINDIR)/tas-statetool
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp lib/libtas_interpose.so $(DESTDIR)$(LIBDIR)/libtas_interpose.so
	cp lib/libtas_sockets.so $(DESTDIR)$(LIBDIR)/libtas_sockets.so
	cp lib/libtas.so $(DESTDIR)$(LIBDIR)/libtas.so

uninstall:
	rm -f $(DESTDIR)$(SBINDIR)/tas
	rm -f $(DESTDIR)$(SBINDIR)/tas-statetool
	rm -f $(DESTDIR)$(LIBDIR)/libtas_interpose.so
	rm -f $(DESTDIR)$(LIBDIR)/libtas_sockets.so
	rm -f $(DESTDIR)$(LIBDIR)/libtas.so


.DEFAULT_GOAL := all
.PHONY: all distclean clean install uninstall

# Include dependencies
-include $(DEPS)
