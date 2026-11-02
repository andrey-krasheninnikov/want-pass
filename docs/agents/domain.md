# Domain docs

Read GLOSSARY.md and relevant docs/adr/ decisions before source exploration.
Перед изучением исходников прочитайте GLOSSARY.md и относящиеся к задаче ADR.

Use one bilingual GLOSSARY.md and numbered bilingual ADRs in docs/adr/.
Используйте один двуязычный GLOSSARY.md и нумерованные двуязычные ADR в docs/adr/.

The glossary defines domain terms without implementation details.
Словарь определяет термины предметной области без деталей реализации.

Record resolved terms and consequential decisions; flag ADR conflicts.
Фиксируйте согласованные термины и существенные решения; отмечайте противоречия ADR.

If domain documents are absent, continue without creating empty files.
Если доменных документов нет, продолжайте без создания пустых файлов.

This repository has a single domain context. Add glossary terms only when agreed and create ADRs for decisions that are costly to reverse, surprising without context and based on a real trade-off. Domain definitions do not replace the product specification or acceptance criteria.

В репозитории один доменный контекст. Добавляйте согласованные термины, а ADR создавайте для решений, которые дорого отменить, непонятны без контекста и основаны на реальном выборе. Определения не заменяют спецификацию и критерии приёмки.
