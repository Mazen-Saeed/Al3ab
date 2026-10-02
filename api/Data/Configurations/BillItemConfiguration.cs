using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class BillItemConfiguration : IEntityTypeConfiguration<BillItem>
{
    public void Configure(EntityTypeBuilder<BillItem> builder)
    {
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_bill_items_quantity", "quantity > 0");
            t.HasCheckConstraint("ck_bill_items_unit_price", "unit_price >= 0");
            t.HasCheckConstraint("ck_bill_items_total", "total = quantity * unit_price");
        });
    }
}
