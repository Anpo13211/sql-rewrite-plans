# SQL rewrite plans

Physical plans of the queries that got faster after an LLM-based rewrite, together with the plans of the original
queries: 56 queries on PostgreSQL 18 and 47 on DuckDB 1.5.5 (TPC-H and TPC-DS, scale factor 10).

## Layout

```
index.csv                      one row per query: engine, query, rewrite_id, speedup, category, note
postgresql/<query>/            56 folders
duckdb/<query>/                47 folders
    original.sql               the original query
    rewrite.sql                the rewritten query
    original.plan.json         plan exactly as returned by the engine
    rewrite.plan.json
    original.plan.txt          the same plan as a readable tree
    rewrite.plan.txt
```

Query names: `tpcds-qNN` and `tpch-qNN`.

## Which rewrite is shown

For each query, the rewrite with the highest median speed-up among the candidates that were at least 1.10x faster in
all 5 measurement rounds when run alone. The candidates were generated with the ReSequel method (gpt-5.6-sol candidate
set) and checked to return the same result as the original on this data. `rewrite_id` is the internal candidate id.

## How the plans were collected

- **PostgreSQL**: `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SETTINGS, FORMAT JSON)`, one run after a warm-up, data in
  memory (32 GB buffer pool), no concurrent load, up to 31 parallel workers per Gather. There is no per-node timing.
  In the text tree, `rows` and `loops` are the actual values per loop, `est_rows` is the planner's estimate, and
  `buffers` are the pages touched by the node and its children.
- **DuckDB**: `EXPLAIN (ANALYZE, FORMAT JSON)` with 8 threads, one run after a warm-up. Operator times are summed over
  the threads.
- **speedup** in `index.csv`: median over 5 rounds of (time of the original / time of the rewrite), each run alone
  (PostgreSQL in memory, DuckDB with 32 threads). It was not measured in the same run as the plans, so the times inside
  the plans do not reproduce it exactly.

## Categories in index.csv

Each query is counted once, under its main change. Many queries show more than one change.

| PostgreSQL | queries |
|---|---:|
| Correlated subquery flattened | 6 |
| Repeated scans become one scan | 15 |
| Nested loop join becomes hash join | 14 |
| Aggregation or filter pushed down | 6 |
| Other join method or join order | 6 |
| Better access path | 4 |
| Aggregation method | 3 |
| Other: join dropped, filter order | 2 |

| DuckDB | queries |
|---|---:|
| Table scanned fewer times | 16 |
| Fewer rows through the plan | 7 |
| Subquery flattened in SQL | 6 |
| Same rows, still faster | 17 |
| Same plan | 1 |

The first three PostgreSQL categories and all DuckDB categories come from rules fixed before the plans were read. The
other 21 PostgreSQL queries were assigned by reading each pair of plans.

## Caveats

- PostgreSQL `tpcds-q82`: the rewrite drops the join with `store_sales`. It returns the same result on this data, but
  it is not equivalent in general.
- DuckDB `tpcds-q25`: measured again with 1 to 32 threads, the rewrite shows no real gain (1.00 to 1.05x).
- The query texts are derived from the TPC-H and TPC-DS benchmark specifications.
