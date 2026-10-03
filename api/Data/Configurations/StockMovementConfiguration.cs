using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class StockMovementConfiguration : IEntityTypeConfiguration<StockMovement>
{
    public void Configure(EntityTypeBuilder<StockMovement> builder)
    {
        builder.ToTable(t =>
        {
            // A count may be 0 (shelf empty); a purchase or an opened tin must be at least 1.
            t.HasCheckConstraint("ck_stock_movements_quantity",
                "(kind = 'Count' AND quantity >= 0) OR (kind <> 'Count' AND quantity > 0)");

            // Only a purchase belongs to a shopping trip; only a count has an expected number.
            t.HasCheckConstraint("ck_stock_movements_purchase", "purchase_id IS NULL OR kind = 'Purchase'");
            t.HasCheckConstraint("ck_stock_movements_expected", "expected_quantity IS NULL OR kind = 'Count'");
        });
    }
}
