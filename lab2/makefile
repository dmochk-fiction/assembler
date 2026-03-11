# Имя исполняемого файла
TARGET = prog
# Исходный файл
SOURCE = prog.s
# Объектный файл
OBJECT = prog.o

# Ассемблер и линкер
ASM = nasm
LD = ld

# Флаги для NASM (x86_64, формат ELF) - добавлен -g для отладки
ASMFLAGS = -f elf64 -g
# Флаги для линковщика
LDFLAGS = 

# Правило по умолчанию
all: $(TARGET)

# Сборка исполняемого файла
$(TARGET): $(OBJECT)
	$(LD) $(LDFLAGS) -o $@ $^

# Компиляция ассемблерного файла в объектный
$(OBJECT): $(SOURCE)
	$(ASM) $(ASMFLAGS) -o $@ $^

# Запуск программы с аргументом (make run ARG=ASC)
run: $(TARGET)
	./$(TARGET) $(ARG)

# Запуск GDB (просто gdb)
gdb: $(TARGET)
	gdb ./$(TARGET)

# Запуск GDB с аргументом ASC
gdb-asc: $(TARGET)
	gdb -ex "run ASC" ./$(TARGET)

# Запуск GDB с аргументом DESC
gdb-desc: $(TARGET)
	gdb -ex "run DESC" ./$(TARGET)

# Запуск GDB с произвольным аргументом (make gdb-run ARG=hello)
gdb-run: $(TARGET)
	gdb -ex "run $(ARG)" ./$(TARGET)

# Очистка
clean:
	rm -f $(OBJECT) $(TARGET)

.PHONY: all clean run gdb gdb-asc gdb-desc gdb-run
