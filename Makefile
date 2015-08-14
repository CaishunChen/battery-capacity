CC = clang
CXXFLAGS = -Wall
LIBS = -lm

PROJECT = battery_capacity

HEADERS = gnuplot_i/gnuplot_i.h
OBJECTS = $(PROJECT).o gnuplot_i/gnuplot_i.o

all: $(PROJECT)

$(PROJECT): $(OBJECTS)
	$(CC) $(CXXFLAGS) $(OBJECTS) -o $@ $(LIBS)

debug: CXXFLAGS += -g3 -DDEBUG
debug: $(PROJECT)

%.o: %.c $(HEADERS)
	$(CC) $(CXXFLAGS) -c $< -o $@

clean:
	rm -r gnuplot_i/*.o
	rm -r *.o
	rm -r $(PROJECT)
